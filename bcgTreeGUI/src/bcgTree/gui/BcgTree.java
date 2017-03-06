package bcgTree.gui;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.GridLayout;
import java.awt.TextArea;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.FocusEvent;
import java.awt.event.FocusListener;
import java.awt.image.BufferedImage;
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
import java.util.Properties;
import java.util.Set;
import java.util.TreeMap;

import javax.imageio.ImageIO;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JProgressBar;
import javax.swing.JScrollPane;
import javax.swing.JSpinner;
import javax.swing.JTextField;
import javax.swing.SpinnerNumberModel;
import javax.swing.SwingUtilities;
import javax.swing.UIManager;
import javax.swing.UIManager.LookAndFeelInfo;

public class BcgTree extends JFrame {
	private static final long serialVersionUID = 1L;
	public static final String VERSION = "1.0.9";
	private static final int DEFAULT_TEXTFIELD_COLUMNS = 30;

	public static void main(String[] args) {
		BcgTree mainWindow = new BcgTree();
		mainWindow.pack();
		mainWindow.setVisible(true);
	}

	private Map<String, File> proteomes;
	private String outdir;
	private String hmmsearch_bin = "";
	private String muscle_bin = "";
	private String gblocks_bin = "";
	private String raxml_bin = "";
	private TextArea logTextArea;
	private JPanel proteomesPanel;
	private Map<JTextField, String> proteomeTextFields;
	private JTextField outdirTextField;
	private JProgressBar progressBar;
	private BcgTree self;
	private JButton runButton;
	private JPanel settingsPanel;
	private Map<String, JTextField> programPaths = new HashMap<String, JTextField>();
	private JPanel checkProgramsPanel;
	private JSpinner bootstrapSpinner;
	private JSpinner threadsSpinner;
	private JTextField randomSeedXTextField;
	private JTextField randomSeedPTextField;
	private JTextField hmmfileTextField;
	private JSpinner minProteomesSpinner;
	private JCheckBox allProteomesCheckbox;
	
	public BcgTree(){
		self = this;
		proteomes = new TreeMap<String, File>();
		outdir = System.getProperty("user.home")+"/bcgTree";
		loadGlobalSettings();
		initGUI();
	}
	
	public void initGUI(){
		// Basic settings
		this.setTitle("bcgTree "+VERSION);
		this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		this.setLayout(new BorderLayout());
		// Set look and file
		try {
		    for (LookAndFeelInfo info : UIManager.getInstalledLookAndFeels()) {
		        if ("Nimbus".equals(info.getName())) {
		            UIManager.setLookAndFeel(info.getClassName());
		            break;
		        }
		    }
		} catch (Exception e) {
		    // If Nimbus is not available, you can set the GUI to another look and feel.
		}
		// Add central panel (split in parameter section and log/output section)
		JPanel mainPanel = new JPanel();
		mainPanel.setLayout(new GridLayout(1, 2));
		this.add(mainPanel, BorderLayout.CENTER);
		settingsPanel = new JPanel();
		JScrollPane settingsScrollPane = new JScrollPane(settingsPanel);
		settingsPanel.setLayout(new GridBagLayout());
		mainPanel.add(settingsScrollPane);
		JPanel logPanel = new JPanel();
		logPanel.setLayout(new BorderLayout());
		mainPanel.add(logPanel);
		// Add Elements to settingsPanel
		// proteome settings
		JPanel proteomesPane = new JPanel();
		Accordion proteomeAccordion = new Accordion("Add proteomes", proteomesPane);
		GridBagConstraints c = new GridBagConstraints();
		c.fill = GridBagConstraints.HORIZONTAL;
		c.gridx = 0;
		c.gridy = 0;
		settingsPanel.add(proteomeAccordion, c);
		JButton proteomesAddButton = new JButton("+");
		proteomesAddButton.addActionListener(proteomeAddActionListener);
		proteomesPane.add(proteomesAddButton);
		proteomesPanel = new JPanel();
		proteomesPanel.setLayout(new GridBagLayout());
		proteomesPane.add(proteomesPanel);
		// outputdir settings
		JPanel outdirPane = new JPanel();
		JLabel outdirLabel = new JLabel("Output directory:");
		outdirPane.add(outdirLabel);
		outdirTextField = new JTextField(outdir, DEFAULT_TEXTFIELD_COLUMNS);
		outdirPane.add(outdirTextField);
		JButton outdirChooseButton = new JButton("choose");
		outdirChooseButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				openOutdirChooseDialog();
			}
		});
		outdirPane.add(outdirChooseButton);
		Accordion outdirAccordion = new Accordion("Set output directory", outdirPane);
		c = new GridBagConstraints();
		c.fill = GridBagConstraints.HORIZONTAL;
		c.gridx = 0;
		c.gridy = 1;
		settingsPanel.add(outdirAccordion, c);
		// Add check programms
		JPanel checkProgramsMainPanel = new JPanel(new BorderLayout());
		checkProgramsPanel = new JPanel(new GridBagLayout());
		checkProgramsMainPanel.add(checkProgramsPanel, BorderLayout.CENTER);
		addCheckProgramPanel("hmmsearch", hmmsearch_bin, "hmmsearch-bin", 0);
		addCheckProgramPanel("muscle", muscle_bin, "muscle-bin", 1);
		addCheckProgramPanel("Gblocks", gblocks_bin, "gblocks-bin", 2);
		addCheckProgramPanel("RAxML", raxml_bin, "raxml-bin",3);
		JPanel checkProgramsButtonPanel = new JPanel(new GridLayout(1,2));
		JButton checkProgramsButton = new JButton("check");
		checkProgramsButton.addActionListener(checkProgramsActionListener);
		checkProgramsButtonPanel.add(checkProgramsButton);
		JButton saveProgramsButton = new JButton("save");
		saveProgramsButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				saveGlobalSettings();
			}
		});
		checkProgramsButtonPanel.add(saveProgramsButton);
		checkProgramsMainPanel.add(checkProgramsButtonPanel, BorderLayout.SOUTH);
		
		Accordion checkProgramsAccordion = new Accordion("Check external programs", checkProgramsMainPanel);
		c = new GridBagConstraints();
		c.fill = GridBagConstraints.HORIZONTAL;
		c.gridx = 0;
		c.gridy = 2;
		settingsPanel.add(checkProgramsAccordion, c);
		// Add check programms
		Accordion advancedSettingsAccordion = new Accordion("Advanced settings", getAdvancedSettingsPanel());
		c = new GridBagConstraints();
		c.fill = GridBagConstraints.HORIZONTAL;
		c.gridx = 0;
		c.gridy = 3;
		settingsPanel.add(advancedSettingsAccordion, c);
		// Add "Run" button
		runButton = new JButton("Run");
		c = new GridBagConstraints();
		c.anchor = GridBagConstraints.CENTER;
		c.gridx = 0;
		c.gridy = 4;
		settingsPanel.add(runButton, c);
		runButton.addActionListener(runActionListener);
		// Add bcgTree logo
		try {
			BufferedImage logo = ImageIO.read(getClass().getResource("/bcgTree.png"));
			JLabel picLabel = new JLabel(new ImageIcon(logo));
			logPanel.add(picLabel, BorderLayout.NORTH);
		} catch (IOException e1) {
			e1.printStackTrace();
		}
		// Add log textarea
		logTextArea = new TextArea();
		logTextArea.setEditable(false);
		logPanel.add(logTextArea, BorderLayout.CENTER);
		// Add progressBar
		progressBar = new JProgressBar(0, 100);
		logPanel.add(progressBar, BorderLayout.SOUTH);
		// final adjustments
		SwingUtilities.updateComponentTreeUI(this);
		this.pack();
	}
	
	private JPanel getAdvancedSettingsPanel(){
		JPanel advancedSettingsPanel = new JPanel(new GridLayout(7, 2));
		advancedSettingsPanel.add(new JLabel("--bootstraps"));
		bootstrapSpinner = new JSpinner(new SpinnerNumberModel(10, 1, 1000, 1));
		advancedSettingsPanel.add(bootstrapSpinner);
		advancedSettingsPanel.add(new JLabel("--threads"));
		threadsSpinner = new JSpinner(new SpinnerNumberModel(2, 1, 80, 1));
		advancedSettingsPanel.add(threadsSpinner);
		advancedSettingsPanel.add(new JLabel("--raxml-x-rapidBootstrapRandomNumberSeed"));
		randomSeedXTextField = new JTextField("", DEFAULT_TEXTFIELD_COLUMNS);
		advancedSettingsPanel.add(randomSeedXTextField);
		advancedSettingsPanel.add(new JLabel("--raxml-p-parsimonyRandomSeed"));
		randomSeedPTextField = new JTextField("", DEFAULT_TEXTFIELD_COLUMNS);
		advancedSettingsPanel.add(randomSeedPTextField);
		advancedSettingsPanel.add(new JLabel("--hmmfile"));
		hmmfileTextField = new JTextField(System.getProperty("user.dir")+"/../data/essential.hmm", DEFAULT_TEXTFIELD_COLUMNS);
		advancedSettingsPanel.add(hmmfileTextField);
		advancedSettingsPanel.add(new JLabel("--min-proteomes"));
		minProteomesSpinner = new JSpinner(new SpinnerNumberModel(2, 1, 10000, 1));
		advancedSettingsPanel.add(minProteomesSpinner);
		advancedSettingsPanel.add(new JLabel("--all-proteomes"));
		allProteomesCheckbox = new JCheckBox();
		allProteomesCheckbox.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				minProteomesSpinner.setEnabled(!allProteomesCheckbox.isSelected());
			}
		});
		advancedSettingsPanel.add(allProteomesCheckbox);
		return advancedSettingsPanel;
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
			// Clear Textfield
			logTextArea.setText("");
			logTextArea.setForeground(Color.BLACK);
			// Apply changes to proteome names
			renameProteomes();
			// create outdir and write options file there:
			outdir = outdirTextField.getText();
			new File(outdir).mkdirs();
			PrintWriter writer;
			try {
				writer = new PrintWriter(outdir+"/options.txt", "UTF-8");
				writer.println("--outdir=\""+outdir+"\"");
				writer.println("--bootstraps="+bootstrapSpinner.getValue());
				writer.println("--threads="+threadsSpinner.getValue());
				writer.println("--hmmfile=\""+hmmfileTextField.getText()+"\"");
				if(allProteomesCheckbox.isSelected()){
					writer.println("--all-proteomes");
				} else {
					writer.println("--min-proteomes="+minProteomesSpinner.getValue());
				}
				String pSeed = randomSeedPTextField.getText();
				if(! pSeed.equals("")){
					writer.println("--raxml-p-parsimonyRandomSeed="+pSeed);
				}
				String xSeed = randomSeedXTextField.getText();
				if(! xSeed.equals("")){
					writer.println("--raxml-x-rapidBootstrapRandomNumberSeed="+xSeed);
				}
				for(String p : programPaths.keySet()){
					String path = programPaths.get(p).getText();
					if(!path.equals("")){						
						writer.println("--" + p + "=" + programPaths.get(p).getText());
					}
				}
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
	            PostProcessWorker postProcessWorker = new PostProcessWorker(proc);
	            postProcessWorker.start();
	            progressBar.setIndeterminate(true);
	            runButton.setEnabled(false);
	            
			} catch (Exception e1) {
				e1.printStackTrace();
			}
		}
	};
	
	ActionListener checkProgramsActionListener = new ActionListener() {		
		@Override
		public void actionPerformed(ActionEvent e) {
			// Clear Textfield
			logTextArea.setText("WARNING: It is only checked whether the paths of each program point to an executable file.\nIt is not checked whether it is the correct program.\n\n");
			logTextArea.setForeground(Color.BLACK);
			try {
				String callBcgTree = "perl "+System.getProperty("user.dir")+"/../bin/bcgTree.pl --check-external-programs";
				for(String p : programPaths.keySet()){
					String path = programPaths.get(p).getText();
					if(!path.equals("")){						
						callBcgTree += " --" + p + "=" + programPaths.get(p).getText();
					}
				}
				logTextArea.append(callBcgTree+"\n");
				Process proc = Runtime.getRuntime().exec(callBcgTree);
				// collect stderr
	            StreamGobbler errorGobbler = new StreamGobbler(proc.getErrorStream(), "ERROR");
	            // collect stdout
	            StreamGobbler outputGobbler = new StreamGobbler(proc.getInputStream(), "OUTPUT");
	            // start gobblers
	            errorGobbler.start();
	            outputGobbler.start();
	            PostCheckWorker postCheckWorker = new PostCheckWorker(proc);
	            postCheckWorker.start();
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
	
	private void addCheckProgramPanel(String name, String currentPath, String commandLineOption, int row){
		JLabel checkProgramLabel = new JLabel(name);
		GridBagConstraints c = new GridBagConstraints();
		c.gridx = 0;
		c.gridy = row;
		checkProgramsPanel.add(checkProgramLabel, c);
		JTextField checkProgramTextField = new JTextField(currentPath, DEFAULT_TEXTFIELD_COLUMNS);
		programPaths.put(commandLineOption, checkProgramTextField);
		c = new GridBagConstraints();
		c.fill = GridBagConstraints.HORIZONTAL;
		c.ipadx = 100;
		c.gridx = 1;
		c.gridy = row;
		checkProgramsPanel.add(checkProgramTextField, c);
		JButton outdirChooseButton = new JButton("choose");
		outdirChooseButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				String newPath = openProgramChooseDialog();
				if(newPath != null){
					checkProgramTextField.setText(newPath);
				}
			}
		});
		c = new GridBagConstraints();
		c.gridx = 2;
		c.gridy = row;
		checkProgramsPanel.add(outdirChooseButton, c);
	}
	
	protected String openProgramChooseDialog() {
		JFileChooser chooser = new JFileChooser();
		chooser.setFileSelectionMode(JFileChooser.FILES_ONLY);
		int exitOption = chooser.showOpenDialog(this);
		if(exitOption == JFileChooser.APPROVE_OPTION){
			return chooser.getSelectedFile().getAbsolutePath();
		}
		return null;
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
		int row = 0;
		for(Map.Entry<String, File> entry : proteomes.entrySet()){
			JButton removeButton = new JButton("-");
			removeButton.addActionListener(new ActionListener() {
				@Override
				public void actionPerformed(ActionEvent e) {
					removeProteome(entry.getKey());
				}
			});
			GridBagConstraints c = new GridBagConstraints();
			c.gridx = 0;
			c.gridy = row;
			proteomesPanel.add(removeButton, c);
			JTextField proteomeNameTextField = new JTextField(entry.getKey(), DEFAULT_TEXTFIELD_COLUMNS);
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
			c = new GridBagConstraints();
			c.fill = GridBagConstraints.HORIZONTAL;
			c.gridx = 1;
			c.gridy = row;
			proteomesPanel.add(proteomeNameTextField, c);
			JLabel proteomePathLabel = new JLabel(entry.getValue().getAbsolutePath());
			c = new GridBagConstraints();
			c.fill = GridBagConstraints.HORIZONTAL;
			c.gridx = 2;
			c.gridy = row;
			proteomesPanel.add(proteomePathLabel, c);
			row++;
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
	
	// Helper class to check state of the process and reset GUI on finish
	class PostProcessWorker extends Thread{
		Process process;
		PostProcessWorker(Process process){
			this.process = process;
		}
		public void run(){
			int exitVal;
			try {
				exitVal = this.process.waitFor();
				progressBar.setIndeterminate(false);
				runButton.setEnabled(true);
				if(exitVal != 0){
					progressBar.setValue(0);
					logTextArea.setForeground(Color.RED);
					JOptionPane.showMessageDialog(self, "bcgTree did not complete your job successfully please check the log for details.", "There was an Error", JOptionPane.ERROR_MESSAGE);
				}
				else{
					progressBar.setValue(100);
					JOptionPane.showMessageDialog(self, "bcgTree finished your job successfully. Output is in "+outdir, "Success", JOptionPane.INFORMATION_MESSAGE);
				}
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
	}
	
	class PostCheckWorker extends Thread{
		Process process;
		PostCheckWorker(Process process){
			this.process = process;
		}
		public void run(){
			int exitVal;
			try {
				exitVal = this.process.waitFor();
				if(exitVal != 0){
					logTextArea.setForeground(Color.RED);
				}
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
	}
	
	public void saveGlobalSettings(){
		Properties globalSettings = new Properties();
		for(String p : programPaths.keySet()){
			String path = programPaths.get(p).getText();
			if(!path.equals("")){						
				globalSettings.setProperty(p, path);
			}
		}
		SettingsFileHandler.saveSettings(globalSettings);
	}
	
	public void loadGlobalSettings(){
		Properties globalSettings = SettingsFileHandler.loadSettings();
		if(globalSettings != null){
			hmmsearch_bin = globalSettings.getProperty("hmmsearch-bin", "");
			muscle_bin = globalSettings.getProperty("muscle-bin", "");
			gblocks_bin = globalSettings.getProperty("gblocks-bin", "");
			raxml_bin = globalSettings.getProperty("raxml-bin", "");
		}
	}

}
