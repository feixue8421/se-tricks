package com.aw.scbadapter;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Properties;

import org.apache.camel.Exchange;
import org.apache.camel.Processor;

public class Transformer implements Processor {

	private static final String MAPPING_PREFIX = "--SCB-TO-PROVIEW--: ";
	private static Properties translator = new Properties();

	private static void loadEventTranslator() {
		if (translator.isEmpty()) {
			BufferedReader config = null;
			try {
				//config = new BufferedReader(new FileReader("C:/apache-activemq-5.14.1/conf/emt1209.sql"));
				config = new BufferedReader(new InputStreamReader(Transformer.class.getResourceAsStream("/emt_event.sql")));
				String line = config.readLine();
				while (line != null) {
					if (line.startsWith(MAPPING_PREFIX)) {
						String[] parts = line.substring(MAPPING_PREFIX.length()).split("=");
						if (parts.length == 2) {
							translator.setProperty(parts[0], parts[1]);
						}
					}

					line = config.readLine();
				}
			} catch (FileNotFoundException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			} finally {
				if (config != null) {
					try {
						config.close();
					} catch (IOException e) {
						e.printStackTrace();
					}
				}
			}
		}
	}

	@Override
	public void process(Exchange message) throws Exception {

		loadEventTranslator();

		String host = (String) message.getIn().getHeader("hostname");
		String event = (String) message.getIn().getHeader("errorcode");
		String generateDate = (String) message.getIn().getHeader("sst_date_time");
		String original = message.getIn().getBody(String.class);

		StringBuilder output = new StringBuilder();
		output.append(String.format("%-16s", host).substring(0, 16));
		output.append(generateDate);
		output.append("01");

		String eventNoMapped = translator.getProperty(event);
//		if (eventNoMapped != null) {
//			eventNoMapped = Long.toString(Long.parseLong(eventNoMapped));
//		}
		output.append(String.format("%-6s", eventNoMapped != null ? eventNoMapped : event).substring(0, 6));
		output.append(original);
		output.append("\r\n");

		message.getOut().setBody(output.toString());
	}

}
