package bcgTree.gui;


import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.Properties;

public class SettingsFileHandler {

	private static String settingsFileName = System.getProperty("user.home") + "/.bcgTree";

	public static void saveSettings(Properties props){
		if(props == null){
			return;
		}
		File settingsFile = new File(settingsFileName);
		FileOutputStream fos;
		try {
			fos = new FileOutputStream(settingsFile);
			props.storeToXML(fos, "global bcgTree settings");
			fos.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public static Properties loadSettings() {
		File settingsFile = new File(settingsFileName);
		if (!settingsFile.exists()) {
			return null;
		}
		FileInputStream fis;
		Properties p = new Properties();
		try {
			fis = new FileInputStream(settingsFile);
			p.loadFromXML(fis);
		} catch (Exception e) {
			return null;
		}
		return p;
	}
}