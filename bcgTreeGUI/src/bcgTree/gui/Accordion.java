package bcgTree.gui;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Component;

import javax.swing.Action;
import javax.swing.JButton;
import javax.swing.JPanel;
import javax.swing.UIManager;
import javax.swing.border.LineBorder;

import org.jdesktop.swingx.JXCollapsiblePane;

public class Accordion extends JPanel {
	private static final long serialVersionUID = 1L;
	private String title;
	private Component comp;

	public Accordion(String title, Component comp){
		this.title = title;
		this.comp = comp;
		initGUI();
	}
	
	private void initGUI(){
		this.setLayout(new BorderLayout());
		JXCollapsiblePane collapsiblePane = new JXCollapsiblePane();
		collapsiblePane.add(comp);
		collapsiblePane.setCollapsed(true);
		this.setBorder(new LineBorder(Color.LIGHT_GRAY));
		// get the built-in toggle action
		Action toggleAction = collapsiblePane.getActionMap().get(JXCollapsiblePane.TOGGLE_ACTION);
		// use the collapse/expand icons from the JTree UI
		toggleAction.putValue(JXCollapsiblePane.COLLAPSE_ICON, UIManager.getIcon("Tree.expandedIcon"));
		toggleAction.putValue(JXCollapsiblePane.EXPAND_ICON, UIManager.getIcon("Tree.collapsedIcon"));
		JButton col = new JButton(collapsiblePane.getActionMap().get(JXCollapsiblePane.TOGGLE_ACTION));
		col.setHorizontalAlignment(JButton.LEFT);
		col.setText(this.title);
		this.add(col, BorderLayout.NORTH);
		this.add(collapsiblePane, BorderLayout.CENTER);
	}
}
