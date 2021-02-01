/**
 * 
 */
package Logic;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import java.util.*;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;

/**
 * @author elio
 * This file was used to create stored procedure calls
 *
 */
public class Insert {
	
	int ad_code = 0;
	static FileWriter follow_file;
	static BufferedWriter follow_ad_writer;
	
	public ArrayList<String> search(WebDriver  driver) {
		ArrayList<String> text = new ArrayList<String>();
		WebElement element;
		driver.findElement(By.xpath("//*[@id=\"form\"]/div[2]/div[1]/button")).click();
	    element = driver.findElement(By.xpath("/html/body/div/div[3]/div[2]/div/div/div/div[1]/div/div/p[1]")); //name
	    text.add(element.getText());
	    element = driver.findElement(By.xpath("/html/body/div/div[3]/div[2]/div/div/div/div[1]/div/div/dl[1]/dd[1]")); //address
	    text.add(element.getText());
	    element = driver.findElement(By.xpath("/html/body/div/div[3]/div[2]/div/div/div/div[1]/div/div/dl[1]/dd[2]")); //number phone
	    text.add(element.getText());
	    element = driver.findElement(By.xpath("/html/body/div/div[3]/div[2]/div/div/div/div[1]/div/div/dl[2]/dd[1]")); //email
	    text.add(element.getText());
	    element = driver.findElement(By.xpath("/html/body/div/div[3]/div[2]/div/div/div/div[1]/div/div/dl[2]/dd[3]")); //username
	    text.add(element.getText());
	    element = driver.findElement(By.xpath("/html/body/div/div[3]/div[2]/div/div/div/div[1]/div/div/dl[2]/dd[4]")); //password
	    text.add(element.getText());
	    element = driver.findElement(By.xpath("/html/body/div/div[3]/div[2]/div/div/div/div[1]/div/div/dl[3]/dd[1]")); //credit card
	    text.add(element.getText());
	    element = driver.findElement(By.xpath("/html/body/div/div[3]/div[2]/div/div/div/div[1]/div/div/dl[3]/dd[2]")); //expiration date
	    text.add(element.getText());
	    return text;
	}
	
	public boolean searchCAP(String cap) {
		
		try {
			int c = Integer.parseInt(cap);
			return true;
		}catch(NumberFormatException er) {
				return false;
		}
	}
	
//inserimentoNuovoAnnuncio (IN descrizione VARCHAR(100), IN importo INT, IN foto BINARY, IN ucc_username VARCHAR(45), IN categoria_nome VARCHAR(20))

	public void insertAd(String username, BufferedWriter writer_add) throws IOException {
		String descrizione = "Descrizione: descrizione di default";
		int list_amount[] = {20, 50, 90, 100, 130, 150, 200, 250, 300, 350, 400};
		String list_categoria[] = {"Immobili", "Locali Commerciali", "Motori", "Auto", "Moto", "Accessori", "Abbigliamento", "Orologi e gioielli", "Sport", "Bici", "Elettronica", "Telefonia", "Informatica computer", "Videogames", "Telecomunicazioni", "Elettrodomestici", "Fai da te"};
		int amount = list_amount[(int) (Math.random() *list_amount.length)];
		String foto = null;
		String procedure_call = null;
		String categoria = list_categoria[(int) (Math.random() *list_categoria.length)];
		procedure_call = "call BachecaElettronicadb.inserimentoNuovoAnnuncio('"+descrizione+"', "+amount+", "+foto+", '"+username+"', '"+categoria+"');";
		
		System.out.println(procedure_call);
		
		writer_add.append(procedure_call);	//write on file
		writer_add.newLine();
		writer_add.flush();
		
		ad_code++;
	}
	
	public String deleteSpaces(int length, String spaces) {
		int i = 0;
		String var = "";
		
		while(true) {
			if(i == length)
				break;
			if(spaces.charAt(i) != ' ') {
				var += spaces.charAt(i);
			}
			i++;
		}
		return var;
	}
	
	public String makeDate(String date) {
		String str_to_date = null;
		String text;
		int number = (int) (Math.random()*31);
		String string_number = null;
		
		if(number < 10)
			string_number = "0"+number;
		else
			string_number = ""+number;
		
		if(number == 0)
			string_number = "01";
		
		text = string_number + "-" + date.substring(0, 2) + "-20" + date.substring(3, 5);
		str_to_date = "STR_TO_DATE('"+text+"', '%d-%m-%Y')";
		
		return str_to_date;
	}
	
	
	public void USCC(WebDriver driver) throws IOException {
		
		FileWriter file = new FileWriter("insertUSCC.sql");
		BufferedWriter writer = new BufferedWriter(file);
		ArrayList<String> text = new ArrayList<String>();
		
		writer.append("-- ------------------------------------");	//write on file
		writer.newLine();
		writer.append("USE `BachecaElettronicadb`");	//write on file
		writer.newLine();
		writer.append("-- ------------------------------------");	//write on file
		writer.newLine();
		writer.newLine();
		writer.flush();
		
		int cycle = 50;
	    while(cycle != 0) {
		    //driver.manage().window().setSize(new Dimension(1920, 1053));
		    text = search(driver);
		    
			String procedure_call = null;
			String cognome = null;
			String nome = null;
			String cf = null;
			String residenza = null;
			String fatturazione = null;
			String cap = null;
			String phone = "";
			
			System.out.println("");
			for(String i: text)
				System.out.println(i);
			
			int  length;
			cognome = text.get(0).substring(0, text.get(0).length());
			length = cognome.length();
			
			// Check string
			if(cognome.contains("Dott. "))
				cognome = cognome.substring("Dott. ".length(), length);
			if(cognome.contains("Sig. "))
				cognome = cognome.substring("Sig. ".length(), length);
			if(cognome.contains("Sig.re "))
				cognome = cognome.substring("Sig.re ".length(), length);
			if(cognome.contains("Sig.ra "))
				cognome = cognome.substring("Sig.ra ".length(), length);
			if(cognome.contains("Ing. "))
				cognome = cognome.substring("Ing. ".length(), length);
			if(cognome.contains("Sir. "))
				cognome = cognome.substring("Sir. ".length(), length);
			if(cognome.contains("Dr. "))
				cognome = cognome.substring("Dr. ".length(), length);
			
			length = cognome.length();
			if(cognome.contains("(male)"))
				cognome = cognome.substring(0, length-"(male)".length());
			if(cognome.contains("(female)"))
				cognome = cognome.substring(0, length-"(female)".length());
			
			// Take name and suraname from string
			int x = 0, y = 0, times = 0;
			while(true) {
				if(cognome.charAt(x) == ' ' && times == 1) break;
				if(cognome.charAt(x) == ' ' && times == 0) {
					y = x;
					times++;
					nome = cognome.substring(0, y);
				}
				x++;
			}
			cognome = cognome.substring(y+1, x);
			
			
			// read address without spaces
			residenza = text.get(1);		
			x = 0; y = 0; times = 0;
			while(true) {
				if(residenza.charAt(++x) == ' ' && times == 1) break;
				if(residenza.charAt(x) == ' ') times++;
			}
			residenza = residenza.substring(0, x);
			
			fatturazione = residenza;
			
			cf = takeCF(nome, cognome);		// calculate the fiscal code
			
			length = text.get(1).length();
			cap = text.get(1);
			
			for(int i=0; i<length-5; i++) {
				
				if(searchCAP(cap.substring(i, i+5))) {
					cap = cap.substring(i, i+5);
					break;
				}
			}
			
			
			int i = 0;
			length = text.get(2).length();
			phone = text.get(2);
			if(phone.contains("+")) 
				while(phone.charAt(++i) != ' ');
				
			phone = deleteSpaces(length-i, text.get(2).substring(i, length));		// delete from phone number
			phone = "393"+phone.substring(0, phone.length()-3);
	    				
			procedure_call = "call BachecaElettronicadb.registra_utente_USCC ('"+text.get(4)+"', '"+text.get(5)+"', '"+cf+"', '"+cognome+"', '"+nome+"', '"+residenza+"', "+cap+", '"+fatturazione+"', 'email', '"+text.get(3)+"', 'cellulare', '"+phone+"');";
			System.out.println(procedure_call);
			
			followAd(text.get(4), 0);
			
			cycle--;
			
			writer.append(procedure_call);	//write on file
			writer.newLine();
			writer.flush();
	    	}
	    writer.close();
	    follow_ad_writer.close();
	    }
	
	
	public void makeCategory() throws IOException {
		FileWriter file = new FileWriter("insertCategory.sql");
		BufferedWriter category_writer = new BufferedWriter(file);
		
		category_writer.append("-- ------------------------------------");	//write on file
		category_writer.newLine();
		category_writer.append("USE `BachecaElettronicadb`");	//write on file
		category_writer.newLine();
		category_writer.append("-- ------------------------------------");	//write on file
		category_writer.newLine();
		category_writer.newLine();
		category_writer.flush();
		
		String list_categoria[] = {"Immobili", "Locali Commerciali", "Motori", "Auto", "Moto", "Accessori", "Abbigliamento", "Orologi e gioielli", "Sport", "Bici", "Elettronica", "Telefonia", "Informatica computer", "Videogames", "Telecomunicazioni", "Elettrodomestici", "Fai da te"};
		String stored_procedure = null;
		
		for (String i: list_categoria) {
			stored_procedure = "call inserimentoNuovaCategoria('"+i+"');";
			System.out.println(stored_procedure);
			category_writer.append(stored_procedure);
			category_writer.newLine();
			category_writer.newLine();
			category_writer.flush();
		}
		
		category_writer.close();
	}
	
//BachecaElettronicadb.registra_utente_USCC (username VARCHAR(45), password VARCHAR(45), cf_anagrafico VARCHAR(16), cognome VARCHAR(20), nome VARCHAR(20), indirizzoDiResidenza VARCHAR(20), cap INT, indirizzoDiFatturazione VARCHAR(20), tipoRecapitoPreferito VARCHAR(20), recapitoPreferito VARCHAR(20), tipoRecapitoNonPreferito VARCHAR(20), recapitoNonPreferito VARCHAR(20))

//BachecaElettronicadb.seguiAnnuncioUCC (codice_annuncio INT, ucc_username VARCHAR(45))

	public void followAd(String ucc_username, int except) throws IOException {
		
		String procedure_call = null;
		int code = (int) (Math.random()*ad_code)-except+1;
		
		procedure_call = "call BachecaElettronicadb.segui_Annuncio ("+code+", '"+ucc_username+"');";
		System.out.println(procedure_call);
		
		follow_ad_writer.append(procedure_call);
		follow_ad_writer.newLine();
		follow_ad_writer.newLine();
		follow_ad_writer.flush();
	}
	
	
	
	public void takeInfo() throws IOException {
		
		WebDriver  driver;
		FileWriter file = new FileWriter("insertUCC.sql");
		BufferedWriter writer = new BufferedWriter(file);
		
		FileWriter file_add = new FileWriter("insertAd.sql");
		BufferedWriter writer_add = new BufferedWriter(file_add);
		
		writer.append("-- ------------------------------------");	//write on file
		writer.newLine();
		writer.append("USE `BachecaElettronicadb`");	//write on file
		writer.newLine();
		writer.append("-- ------------------------------------");	//write on file
		writer.newLine();
		writer.newLine();
		writer.flush();
		
		writer_add.append("-- ------------------------------------");	//write on file
		writer_add.newLine();
		writer_add.append("USE `BachecaElettronicadb`");	//write on file
		writer_add.newLine();
		writer_add.append("-- ------------------------------------");	//write on file
		writer_add.newLine();
		writer_add.newLine();
		writer_add.flush();
		
		ArrayList<String> text = new ArrayList<String>();
		System.setProperty("webdriver.chrome.driver", "/usr/bin/chromedriver");
		driver = new ChromeDriver();
	    driver.get("https://www.random-name-generator.com/italy?country=it_IT&gender=&n=1&s=49644#form");
	    
	    int cycle = 90;
	    while(cycle != 0) {
		    //driver.manage().window().setSize(new Dimension(1920, 1053));
		    text = search(driver);
		    
			String procedure_call = null;
			String cognome = null;
			String nome = null;
			String cvc = null;
			String cf = null;
			String residenza = null;
			String fatturazione = null;
			String cap = null;
			String creditCard = "";
			String phone = "";
			String date = null;
			
			System.out.println("");
			for(String i: text)
				System.out.println(i);
			
			int  length;
			cognome = text.get(0).substring(0, text.get(0).length());
			length = cognome.length();
			
			// Check string
			if(cognome.contains("Dott. "))
				cognome = cognome.substring("Dott. ".length(), length);
			if(cognome.contains("Sig. "))
				cognome = cognome.substring("Sig. ".length(), length);
			if(cognome.contains("Sig.re "))
				cognome = cognome.substring("Sig.re ".length(), length);
			if(cognome.contains("Sig.ra "))
				cognome = cognome.substring("Sig.ra ".length(), length);
			if(cognome.contains("Ing. "))
				cognome = cognome.substring("Ing. ".length(), length);
			if(cognome.contains("Sir. "))
				cognome = cognome.substring("Sir. ".length(), length);
			if(cognome.contains("Dr. "))
				cognome = cognome.substring("Dr. ".length(), length);	
			
			length = cognome.length();
			if(cognome.contains("(male)"))
				cognome = cognome.substring(0, length-"(male)".length());
			if(cognome.contains("(female)"))
				cognome = cognome.substring(0, length-"(female)".length());
			
			// Take name and suraname from string
			int x = 0, y = 0, times = 0;
			while(true) {
				if(cognome.charAt(x) == ' ' && times == 1) break;
				if(cognome.charAt(x) == ' ' && times == 0) {
					y = x;
					times++;
					nome = cognome.substring(0, y);
				}
				x++;
			}
			cognome = cognome.substring(y+1, x);
			
			Random rand = new Random();
			int cvc_number;
			cvc_number = rand.nextInt(999) + 100;	//the minimum is 100 because the cvc is made of 3 numbers
			cvc_number = ((cvc_number) > 999) ? cvc_number-100 : cvc_number;	//check maximum
			cvc = Integer.toString(cvc_number);		// random number min: 100 and max: 999
			
			// read address without spaces
			residenza = text.get(1);		
			x = 0; y = 0; times = 0;
			while(true) {
				if(residenza.charAt(++x) == ' ' && times == 1) break;
				if(residenza.charAt(x) == ' ') times++;
			}
			residenza = residenza.substring(0, x);
			
			fatturazione = residenza;
			
			cf = takeCF(nome, cognome);		// calculate the fiscal code
			
			length = text.get(1).length();
			cap = text.get(1);
			
			for(int i=0; i<length-5; i++) {
				
				if(searchCAP(cap.substring(i, i+5))) {
					cap = cap.substring(i, i+5);
					break;
				}
			}
			
			length = text.get(6).length();
			creditCard = deleteSpaces(length, text.get(6));		// delete spaces from credit card
			
			int i = 0;
			length = text.get(2).length();
			phone = text.get(2);
			if(phone.contains("+")) 
				while(phone.charAt(++i) != ' ');
				
			phone = deleteSpaces(length-i, text.get(2).substring(i, length));		// delete from phone number
			phone = "393"+phone.substring(0, phone.length()-3);
	    	
			date = makeDate(text.get(7));
			
			procedure_call = "call BachecaElettronicadb.registra_utente_UCC ('"+text.get(4)+"', '"+text.get(5)+"', '"+creditCard+"', "+date+", "+cvc+", '"+cf+"', '"+cognome+"', '"+nome+"', '"+residenza+"', "+cap+", '"+fatturazione+"', 'email', '"+text.get(3)+"', 'cellulare', '"+phone+"');";
			System.out.println(procedure_call);
			
			insertAd(text.get(4), writer_add);
			insertAd(text.get(4), writer_add);
			
			followAd(text.get(4), 2);
			
			cycle--;
			
			writer.append(procedure_call);	//write on file
			writer.newLine();
			writer.flush();
	    	}
	    writer.close();
	    writer_add.close();
	    
	    USCC(driver);
	    
	    
	    driver.close();
	}
	

	
	public static String takeCF(String name, String surname) {
		String random_list[] = {"Roma", "Milano", "Torino", "Firenze"};
		String random_list_code[] = {"RM", "MI", "TO", "FI"};
		int index_random = (int) (Math.random() * random_list.length);
		String city = random_list[index_random];
		String code = random_list_code[index_random];
		String cf = null;
		WebDriver driver;
		WebElement element;
		driver = new ChromeDriver();
		driver.get("http://www.codicefiscaleonline.com/");
		driver.findElement(By.xpath("//*[@id=\"input_cognome\"]")).sendKeys(surname);
		driver.findElement(By.xpath("//*[@id=\"input_nome\"]")).sendKeys(name);
		driver.findElement(By.xpath("//*[@id=\"calcolo\"]/div[6]/div[2]/input")).sendKeys(city);
		driver.findElement(By.xpath("//*[@id=\"calcolo\"]/div[7]/div[2]/input")).sendKeys(code);
		driver.findElement(By.xpath("//*[@id=\"qc-cmp2-ui\"]/div[2]/div/button[2]")).click();
		driver.findElement(By.xpath("//*[@id=\"calcolo\"]/div[9]/input")).click();
		element = driver.findElement(By.xpath("//*[@id=\"calcolo\"]/div[2]/div[2]"));
		cf = element.getText();
		driver.close();
		return cf;
	}
		
	public static void main(String[] args) throws IOException {
		Insert var = new Insert();
		
		var.makeCategory();
		
		follow_file = new FileWriter("follow_ad.sql");
		follow_ad_writer = new BufferedWriter(follow_file);
		
		follow_ad_writer.append("-- ------------------------------------");	//write on file
		follow_ad_writer.newLine();
		follow_ad_writer.append("USE `BachecaElettronicadb`");	//write on file
		follow_ad_writer.newLine();
		follow_ad_writer.append("-- ------------------------------------");	//write on file
		follow_ad_writer.newLine();
		follow_ad_writer.flush();
		
		var.takeInfo();
	}	
}
