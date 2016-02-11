package bcgTree.gui;

import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;

public class BcgTree extends JFrame {
	private static final long serialVersionUID = 1L;

	public static void main(String[] args) {
		BcgTree mainWindow = new BcgTree();
		mainWindow.pack();
		mainWindow.setVisible(true);
	}
	
	public BcgTree(){
		this.setTitle("bcgTree");
		this.setLayout(new GridLayout(4, 1));
		JLabel titleLabel = new JLabel("bcgTree v1.0.0");
		titleLabel.setHorizontalAlignment(JLabel.CENTER);
		this.add(titleLabel);
		this.add(new JButton("Check Requirements"));
		this.add(new JButton("Set Parameters"));
		JButton actionButton = new JButton("Action!");
		this.add(actionButton);
		actionButton.addActionListener(new ActionListener() {
			
			@Override
			public void actionPerformed(ActionEvent e) {
				System.out.println(System.getProperty("user.dir"));
				try {
					Process proc = Runtime.getRuntime().exec("perl "+System.getProperty("user.dir")+"/../bin/bcgTree.pl --help");
					InputStream stderr = proc.getInputStream();
		            InputStreamReader isr = new InputStreamReader(stderr);
		            BufferedReader br = new BufferedReader(isr);
		            String line = null;
		            while ( (line = br.readLine()) != null)
		                System.out.println(line);
		            int exitVal = proc.waitFor();
		            System.out.println("Process exitValue: " + exitVal);
				} catch (IOException | InterruptedException e1) {
					e1.printStackTrace();
				}
			}
		});
	}

}
