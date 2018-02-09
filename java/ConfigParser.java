package com.aw.scbadapter;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;

import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.velocity.Template;
import org.apache.velocity.VelocityContext;
import org.apache.velocity.app.Velocity;
import org.apache.velocity.runtime.RuntimeConstants;
import org.apache.velocity.tools.generic.EscapeTool;

public class ConfigParser {
	private Map<Integer, String> xlsHeader = new HashMap<Integer, String>();
	private ArrayList<Map<Integer, String>> xlsData = new ArrayList<Map<Integer, String>>();
	private Properties messageTune = new Properties();

	private static final int MESSAGE_NO_STARTS = 600000;
	private static final int MESSAGE_NO_ENDS = 700000;
	private static final String INSERT_MESSAGE_HEAD = "DELETE eventconversion WHERE devicetype = 0 AND eventno BETWEEN $EVENT_START$ AND $EVENT_END$;"
			+ "\r\nDELETE eventbase WHERE eventno BETWEEN $EVENT_START$ AND $EVENT_END$;"
			+ "\r\nDELETE message0001 WHERE texttype = 1 AND textno BETWEEN $EVENT_START$ AND $EVENT_END$;";
	private static final String INSERT_MESSAGE = "--SCB-TO-PROVIEW--: $SCBNO$=$EVTID$"
			+ "\r\nINSERT INTO message0001 (textno, texttype, messagetext) VALUES ($EVTID$, 1, N'$EVTMESSAGE$');"
			+ "\r\nINSERT INTO eventbase(eventno, textno, texttype, setbit, unsetbit, componentid, compsetbit, compunsetbit, target, forwarddesktop, forwardrule, eventgroupid, confidential, confidentialmask, masktype) VALUES ($EVTID$, $EVTID$, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, NULL, -1);";
	private static final String INSERT_EVENT_CONVERSION = "INSERT INTO eventconversion SELECT e.eventno, 0, e.eventno, m.messagetext FROM eventbase e INNER JOIN message0001 m ON e.eventno = m.textno AND m.texttype = 1 WHERE e.eventno BETWEEN $EVENT_START$ AND $EVENT_END$;";

	private static final String INSERT_DEVICE = "INSERT INTO device (hierlevel, devicetype, act_transport, transport1, transportid1, transport2, transportid2, agenttype, customer_contactid, techn_contactid, supplier_contactid, position, url, multiplexer, outgoingcalls, deviceid) values ('0', 2, '1', 'TCP', '1', NULL, NULL, NULL, NULL, NULL, NULL, '', NULL, '0', 'Y', '$DEVICE$');"
			+ "\r\nINSERT INTO state (devicestate, eventcount, extraeventcount, eventid, agmname, timestamp, connsuccesscount, connfailurecount, conndetailcount, conndetailsuccesscount, conndetailfailurecount, deviceid) VALUES (2048, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '$DEVICE$');"
			+ "\r\nINSERT INTO transport (remotedte, remotecud, localcud, deviceid, transportid) VALUES ('ATMDUMMY', '18988', NULL, '$DEVICE$', '1');";

	@SuppressWarnings("deprecation")
	private static void readRowData(HSSFRow row, Map<Integer, String> data) {
		if (row != null) {
			Iterator<Cell> it = row.cellIterator();

			while (it.hasNext()) {
				Cell cell = it.next();
				switch (cell.getCellType()) {
				case Cell.CELL_TYPE_NUMERIC:
					data.put(cell.getAddress().getColumn(), Long.toString(Math.round(cell.getNumericCellValue())));
					break;
				case Cell.CELL_TYPE_STRING:
					data.put(cell.getAddress().getColumn(), cell.getStringCellValue().trim());
					break;
				default:
					data.put(cell.getAddress().getColumn(), "");
					break;
				}
			}
		}
	}

	public void loadExcel(String sheetName, int headerPos) {
		HSSFWorkbook wb = null;
		try {
			POIFSFileSystem fs = new POIFSFileSystem(getClass().getResourceAsStream("/scb.xls"));
			wb = new HSSFWorkbook(fs);
			HSSFSheet sheet = wb.getSheet(sheetName);

			// read xls header
			readRowData(sheet.getRow(headerPos), xlsHeader);

			// read xls data
			for (int idx = headerPos + 1; idx <= sheet.getLastRowNum(); idx++) {
				Map<Integer, String> rowData = new HashMap<Integer, String>();
				readRowData(sheet.getRow(idx), rowData);
				xlsData.add(rowData);
			}
		} catch (Exception ioe) {
			ioe.printStackTrace();
		} finally {
			if (wb != null) {
				try {
					wb.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
	}

	private void printConfigData() {
		// print config data
		System.out.println("--------------config data--------------");
		for (Map<Integer, String> rowData : xlsData) {
			for (Integer column : xlsHeader.keySet()) {
				if (rowData.containsKey(column) && !rowData.get(column).isEmpty()) {
					System.out.println(xlsHeader.get(column) + ": " + rowData.get(column));
				} else {
					System.out.println("----" + xlsHeader.get(column) + ": ");
				}
			}

			System.out.println();
		}
	}

	private void printEventMessage() throws IOException {
		// insert into table eventbase and message0001
		System.out.println("--------------event message--------------");
		System.out.println(INSERT_MESSAGE_HEAD.replace("$EVENT_START$", Integer.toString(MESSAGE_NO_STARTS))
				.replace("$EVENT_END$", Integer.toString(MESSAGE_NO_ENDS)));
		System.out.println();

		int eventNo = MESSAGE_NO_STARTS + 1;
		for (Map<Integer, String> rowData : xlsData) {
			System.out.println(
					INSERT_MESSAGE.replace("$EVTID$", Integer.toString(eventNo)).replace("$SCBNO$", rowData.get(3))
							.replace("$EVTMESSAGE$", tuneMessage(rowData.get(3), rowData.get(1))));
			eventNo++;

			System.out.println();
		}

		// insert into table eventconversion
		System.out.println("--------------eventconversion--------------");
		System.out.println(INSERT_EVENT_CONVERSION.replace("$EVENT_START$", Integer.toString(MESSAGE_NO_STARTS))
				.replace("$EVENT_END$", Integer.toString(MESSAGE_NO_ENDS)));
	}

	private void printInsertDevice() {
		// print device sql
		System.out.println("--------------insert device--------------");
		for (Map<Integer, String> rowData : xlsData) {
			if (rowData.get(0) != null) {
				System.out.println(INSERT_DEVICE.replace("$DEVICE$", rowData.get(0)));
				System.out.println();
			}
		}
	}
	
	private void initializeVelocity() {
		Properties velocityProps = new Properties();
		velocityProps.setProperty(RuntimeConstants.RUNTIME_LOG_LOGSYSTEM_CLASS,
				"org.apache.velocity.runtime.log.NullLogSystem");
		velocityProps.setProperty(RuntimeConstants.RESOURCE_LOADER, "class");
		velocityProps.setProperty("class.resource.loader.class",
				"org.apache.velocity.runtime.resource.loader.ClasspathResourceLoader");

		Velocity.init(velocityProps);		
	}
	

	public void printInsertDeviceAndBaseData() throws Exception {
		initializeVelocity();
		VelocityContext context = new VelocityContext();
		context.put("data", xlsData);
		context.put("column", xlsHeader);
		context.put("basedatastarts", 1000);
		context.put("esc", new EscapeTool());

		Template template = Velocity.getTemplate("/device_template.vm");

		BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(System.out));
		template.merge(context, writer);

		writer.flush();
		writer.close();
	}

	private String tuneMessage(String event, String message) throws IOException {
		if (messageTune.isEmpty()) {
			messageTune.load(getClass().getResourceAsStream("/message_tune.properties"));
		}

		return messageTune.getProperty(event, message);
	}

	public ArrayList<String> getDataByColumn(int index) {
		ArrayList<String> result = new ArrayList<String>();

		for (Map<Integer, String> rowData : xlsData) {
			result.add(rowData.get(index));
		}

		return result;
	}

	public ArrayList<String> getDataByColumn(String column) {
		int index = -1;
		for (Map.Entry<Integer, String> entry : xlsHeader.entrySet()) {
			if (entry.getValue().equals(column)) {
				index = entry.getKey().intValue();
				break;
			}
		}

		return index != -1 ? getDataByColumn(index) : null;
	}

	public Map<Integer, String> getHeader() {
		return xlsHeader;
	}

	public static void main(String[] args) throws Exception {

		ConfigParser parser = new ConfigParser();

		if (args.length > 0) {
			switch (args[0]) {
			case "device":
				parser.loadExcel("MasterData", 1);
				parser.printInsertDeviceAndBaseData();
				break;
			case "message":
				parser.loadExcel("EMT SCB-CN", 0);
				parser.printConfigData();
				parser.printEventMessage();
				break;
			default:
				break;
			}

		} else {
			System.out.println(
					"Parameter missing! Please re-execute the program and input [device]/[message] as its parameter!");
		}

	}

}
