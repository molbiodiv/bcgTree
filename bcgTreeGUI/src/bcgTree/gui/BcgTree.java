package bcgTree.gui;

import java.awt.BorderLayout;
import java.awt.GridLayout;
import java.awt.TextArea;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;

public class BcgTree extends JFrame {
	private static final long serialVersionUID = 1L;

	public static void main(String[] args) {
		BcgTree mainWindow = new BcgTree();
		mainWindow.pack();
		mainWindow.setVisible(true);
	}

	private TextArea logTextArea;
	
	public BcgTree(){
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
		//TODO
		// Add log textarea
		logTextArea = new TextArea();
		logTextArea.setEditable(false);
		logPanel.add(logTextArea, BorderLayout.CENTER);
		
		this.pack();
	}
	
	ActionListener runActionListener = new ActionListener() {		
		@Override
		public void actionPerformed(ActionEvent e) {
			System.out.println(System.getProperty("user.dir"));
			try {
				Process proc = Runtime.getRuntime().exec("perl "+System.getProperty("user.dir")+"/../bin/bcgTree.pl --help");
				InputStream stdout = proc.getInputStream();
	            InputStreamReader isr = new InputStreamReader(stdout);
	            BufferedReader br = new BufferedReader(isr);
	            String line = null;
	            while ( (line = br.readLine()) != null)
	                logTextArea.append(line + "\n");
	            int exitVal = proc.waitFor();
	            System.out.println("Process exitValue: " + exitVal);
			} catch (IOException | InterruptedException e1) {
				e1.printStackTrace();
			}
		}
	};

}
