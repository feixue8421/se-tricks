package com.aw.scbadapter;

import org.apache.activemq.ActiveMQConnection;
import org.apache.activemq.ActiveMQConnectionFactory;
import org.apache.activemq.command.ActiveMQTextMessage;

import java.util.Date;

import javax.jms.Connection;
import javax.jms.DeliveryMode;
import javax.jms.Destination;
import javax.jms.MessageProducer;
import javax.jms.Session;

public class ProducerAgent extends Thread {

	public static void main(String[] args) throws Exception {
		new ProducerAgent().start();
	}

	public void run() {
		try {

			ActiveMQConnectionFactory connectionFactory = new ActiveMQConnectionFactory(user, password, url);
			Connection connection = connectionFactory.createConnection();
			connection.start();

			Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
			Destination destination = session.createQueue("TOOL.DEFAULT");

			MessageProducer producer = session.createProducer(destination);
			producer.setDeliveryMode(DeliveryMode.NON_PERSISTENT);

			ActiveMQTextMessage amqmessage = new ActiveMQTextMessage();
			String text = "Hello world! Date: " + new Date();
			amqmessage.setText(text);
			amqmessage.setStringProperty("sst_date_time", "20161117172605");
			amqmessage.setStringProperty("hostname", "ATM001");
			amqmessage.setStringProperty("class", "scbchina");
			amqmessage.setStringProperty("errorcode", "13360");
			amqmessage.setReadOnlyBody(true);
			producer.send(amqmessage);

			session.close();
			connection.close();
		} catch (Exception e) {
			System.out.println("Caught: " + e);
			e.printStackTrace();
		}
	}

	private String user = ActiveMQConnection.DEFAULT_USER;
	private String password = ActiveMQConnection.DEFAULT_PASSWORD;
	private String url = ActiveMQConnection.DEFAULT_BROKER_URL;
}
