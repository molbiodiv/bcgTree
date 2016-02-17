package bcgTree.gui;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.GridLayout;
import java.awt.TextArea;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.FocusEvent;
import java.awt.event.FocusListener;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import javax.swing.JButton;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JTextField;

public class BcgTree extends JFrame {
	private static final long serialVersionUID = 1L;

	public static void main(String[] args) {
		BcgTree mainWindow = new BcgTree();
		mainWindow.pack();
		mainWindow.setVisible(true);
	}

	private TextArea logTextArea;
	private GridLayout proteomesPanelLayout;
	private JPanel proteomesPanel;
	private Map<String, File> proteomes;
	private Map<JTextField, String> proteomeTextFields;
	private String outdir;
	private JTextField outdirTextField;
	
	public BcgTree(){
		proteomes = new TreeMap<String, File>();
		outdir = System.getProperty("user.home")+"/bcgTree";
		initGUI();
	}
	
	public void initGUI(){
		// Basic settings
		this.setTitle("bcgTree");
		this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		this.setLayout(new BorderLayout());
		// Add title
		JLabel titleLabel = new JLabel("bcgTree v1.0.0");
		titleLabel.setHorizontalAlignment(JLabel.CENTER);
		this.add(titleLabel, BorderLayout.NORTH);
		// Add "Run" button
		JButton runButton = new JButton("Run");
		this.add(runButton, BorderLayout.SOUTH);
		runButton.addActionListener(runActionListener);
		// Add central panel (split in parameter section and log/output section)
		JPanel mainPanel = new JPanel();
		mainPanel.setLayout(new GridLayout(1, 2));
		this.add(mainPanel, BorderLayout.CENTER);
		JPanel settingsPanel = new JPanel();
		mainPanel.add(settingsPanel);
		JPanel logPanel = new JPanel();
		logPanel.setLayout(new BorderLayout());
		mainPanel.add(logPanel);
		// Add Elements to settingsPanel
		// proteome settings
		JLabel proteomesLabel = new JLabel("Proteomes");
		settingsPanel.add(proteomesLabel);
		JButton proteomesAddButton = new JButton("+");
		proteomesAddButton.addActionListener(proteomeAddActionListener);
		settingsPanel.add(proteomesAddButton);
		proteomesPanel = new JPanel();
		proteomesPanelLayout = new GridLayout(0, 3);
		proteomesPanel.setLayout(proteomesPanelLayout);
		settingsPanel.add(proteomesPanel);
		// outputdir settings
		JLabel outdirLabel = new JLabel("Output directory:");
		settingsPanel.add(outdirLabel);
		outdirTextField = new JTextField(outdir);
		outdirTextField.setEditable(false);
		settingsPanel.add(outdirTextField);
		JButton outdirChooseButton = new JButton("choose");
		outdirChooseButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				openOutdirChooseDialog();
			}
		});
		settingsPanel.add(outdirChooseButton);
		// Add log textarea
		logTextArea = new TextArea();
		logTextArea.setForeground(Color.red);
		logTextArea.setEditable(false);
		logPanel.add(logTextArea, BorderLayout.CENTER);
		// final adjustments
		this.pack();
	}
	
	protected void openOutdirChooseDialog() {
		JFileChooser chooser = new JFileChooser();
		chooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
		int exitOption = chooser.showOpenDialog(this);
		if(exitOption == JFileChooser.APPROVE_OPTION){
			outdir = chooser.getSelectedFile().getAbsolutePath();
			outdirTextField.setText(outdir);
		}
	}

	ActionListener runActionListener = new ActionListener() {		
		@Override
		public void actionPerformed(ActionEvent e) {
			// Apply changes to proteome names
			renameProteomes();
			// create outdir and write options file there:
			new File(outdir).mkdirs();
			PrintWriter writer;
			try {
				writer = new PrintWriter(outdir+"/options.txt", "UTF-8");
				writer.println("--outdir \""+outdir+"\"");
				for(Map.Entry<String, File> entry: proteomes.entrySet()){					
					writer.println("--proteome "+entry.getKey()+"="+"\""+entry.getValue().getAbsolutePath()+"\"");
				}
				writer.close();
			} catch (FileNotFoundException | UnsupportedEncodingException e2) {
				e2.printStackTrace();
			}
			try {
				Process proc = Runtime.getRuntime().exec("perl "+System.getProperty("user.dir")+"/../bin/bcgTree.pl @"+outdir+"/options.txt");
				// collect stderr
	            StreamGobbler errorGobbler = new StreamGobbler(proc.getErrorStream(), "ERROR");
	            // collect stdout
	            StreamGobbler outputGobbler = new StreamGobbler(proc.getInputStream(), "OUTPUT");
	            // start gobblers
	            errorGobbler.start();
	            outputGobbler.start();
	            //int exitVal = proc.waitFor();
	            //System.out.println("Process exitValue: " + exitVal);
			} catch (Exception e1) {
				e1.printStackTrace();
			}
		}
	};
	
	ActionListener proteomeAddActionListener = new ActionListener() {
		@Override
		public void actionPerformed(ActionEvent e) {
			proteomeAddAction();
		}
	};
	
	public void proteomeAddAction(){
		JFileChooser chooser = new JFileChooser();
		chooser.setMultiSelectionEnabled(true);
		int exitOption = chooser.showOpenDialog(this);
		if(exitOption != JFileChooser.APPROVE_OPTION){
			return;
		}
		File[] files = chooser.getSelectedFiles();
		proteomesPanelLayout.setRows(files.length);
		for(int i=0; i<files.length; i++){
			String name = files[i].getName().replace(" ", "_");
			String path = files[i].getAbsolutePath();
			// avoid name collisions (does not matter if name and path are identical)
			if(proteomes.get(name) != null && !proteomes.get(name).getAbsolutePath().equals(path)){
				int suffix = 1;
				while(proteomes.get(name+"_"+suffix) != null && !proteomes.get(name+"_"+suffix).getAbsolutePath().equals(path)){
					suffix++;
				}
				name = name + "_" + suffix;
			}
			proteomes.put(name, files[i]);
		}
		updateProteomePanel();
	}
	
	public void removeProteome(String name){
		proteomes.remove(name);
		renameProteomes();
		updateProteomePanel();
	}
	
	public void renameProteomes(){
		TreeMap<String, File> newProteomes = new TreeMap<String, File>();
		for(Map.Entry<JTextField, String> entry: proteomeTextFields.entrySet()){
			if(proteomes.containsKey(entry.getValue())){
				newProteomes.put(entry.getKey().getText(), proteomes.get(entry.getValue()));
			}
		}
		proteomes = newProteomes;
	}
	
	public void updateProteomePanel(){
		proteomesPanel.removeAll();
		proteomeTextFields = new HashMap<JTextField, String>();
		proteomesPanelLayout.setRows(proteomes.size());
		for(Map.Entry<String, File> entry : proteomes.entrySet()){
			JButton removeButton = new JButton("-");
			removeButton.addActionListener(new ActionListener() {
				@Override
				public void actionPerformed(ActionEvent e) {
					removeProteome(entry.getKey());
				}
			});
			proteomesPanel.add(removeButton);
			JTextField proteomeNameTextField = new JTextField(entry.getKey());
			proteomeNameTextField.addFocusListener(new FocusListener() {
				@Override
				public void focusLost(FocusEvent e) {
					if(e.isTemporary()){
						return;
					}
					if(proteomeNameTextField.getText().contains(" ")){
						proteomeNameTextField.setText(proteomeNameTextField.getText().replace(" ", "_"));
						showSpaceInProteomeNameWarningDialog();
					}
					checkDuplicateProteomeNames();
				}
				@Override
				public void focusGained(FocusEvent e) {	
				}
			});
			proteomeTextFields.put(proteomeNameTextField, entry.getKey());
			proteomesPanel.add(proteomeNameTextField);
			JLabel proteomePathLabel = new JLabel(entry.getValue().getAbsolutePath());
			proteomesPanel.add(proteomePathLabel);
		}
		this.revalidate();
		this.repaint();
	}
	
	protected void showSpaceInProteomeNameWarningDialog() {
		JOptionPane.showMessageDialog(this, "The proteome name contained spaces, those have been automatically replaced by underscores.", "Whitespace Replace Warning", JOptionPane.WARNING_MESSAGE);
	}

	protected void checkDuplicateProteomeNames(){
		Set<String> usedNames = new HashSet<String>();
		for(JTextField tf: proteomeTextFields.keySet()){
			String name = tf.getText();
			if(usedNames.contains(name)){
				JOptionPane.showMessageDialog(this, "The name: '"+name+"' is used twice for different proteomes. Please fix otherwise one of the entries will be lost.", "Duplicate Name Warning", JOptionPane.WARNING_MESSAGE);
			}
			usedNames.add(name);
		}
	}
	
	// Helper class to process stdout and stderr of the command
	// see http://www.javaworld.com/article/2071275/core-java/when-runtime-exec---won-t.html?page=2
	class StreamGobbler extends Thread
	{
	    InputStream is;
	    String type;
	    
	    StreamGobbler(InputStream is, String type)
	    {
	        this.is = is;
	        this.type = type;
	    }
	    
	    public void run()
	    {
	        try
	        {
	            InputStreamReader isr = new InputStreamReader(is);
	            BufferedReader br = new BufferedReader(isr);
	            String line=null;
	            while ( (line = br.readLine()) != null)
	            	logTextArea.append(line + "\n");
	            } catch (IOException ioe)
	              {
	                ioe.printStackTrace();  
	              }
	    }
	}

}
