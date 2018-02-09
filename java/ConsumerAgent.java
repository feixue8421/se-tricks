package com.aw.scbadapter;

import javax.jms.Connection;
import javax.jms.DeliveryMode;
import javax.jms.Destination;
import javax.jms.ExceptionListener;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageConsumer;
import javax.jms.MessageListener;
import javax.jms.MessageProducer;
import javax.jms.Session;
import javax.jms.TextMessage;
import javax.jms.Topic;

import org.apache.activemq.ActiveMQConnection;
import org.apache.activemq.ActiveMQConnectionFactory;

public class ConsumerAgent extends Thread implements MessageListener, ExceptionListener {

	private Session session;
	private Destination destination;
	private MessageProducer replyProducer;

	private boolean verbose = true;

	private String subject = "TOOL.DEFAULT";
	private boolean topic = false;
	private String user = ActiveMQConnection.DEFAULT_USER;
	private String password = ActiveMQConnection.DEFAULT_PASSWORD;
	private String url = ActiveMQConnection.DEFAULT_BROKER_URL;
	private boolean transacted;
	private boolean durable;
	private String clientId;
	private int ackMode = Session.AUTO_ACKNOWLEDGE;
	private String consumerName = "James";

	private long batch = 10; // Default batch size for CLIENT_ACKNOWLEDGEMENT or
								// SESSION_TRANSACTED
	private long messagesReceived = 0;

	public void showParameters() {
		System.out.println("Connecting to URL: " + url);
		System.out.println("Consuming " + (topic ? "topic" : "queue") + ": " + subject);
		System.out.println("Using a " + (durable ? "durable" : "non-durable") + " subscription");
	}

	public void run() {
		try {

			ActiveMQConnectionFactory connectionFactory = new ActiveMQConnectionFactory(user, password, url);
			Connection connection = connectionFactory.createConnection();
			if (durable && clientId != null && clientId.length() > 0 && !"null".equals(clientId)) {
				connection.setClientID(clientId);
			}
			connection.setExceptionListener(this);
			connection.start();

			session = connection.createSession(transacted, ackMode);
			if (topic) {
				destination = session.createTopic(subject);
			} else {
				destination = session.createQueue(subject);
			}

			replyProducer = session.createProducer(null);
			replyProducer.setDeliveryMode(DeliveryMode.NON_PERSISTENT);

			MessageConsumer consumer = null;
			if (durable && topic) {
				consumer = session.createDurableSubscriber((Topic) destination, consumerName);
			} else {
				consumer = session.createConsumer(destination);
			}

			consumer.setMessageListener(this);

			// consumeMessagesAndClose(connection, session, consumer,
			// receiveTimeOut);

		} catch (Exception e) {
			System.out.println("[" + this.getName() + "] Caught: " + e);
			e.printStackTrace();
		}
	}

	public void onMessage(Message message) {
		try {

			if (message instanceof TextMessage) {
				TextMessage txtMsg = (TextMessage) message;
				if (verbose) {

					String msg = txtMsg.getText();
					int length = msg.length();
					if (length > 50) {
						msg = msg.substring(0, 50) + "...";
					}
					System.out.println("[" + this.getName() + "] Received: '" + msg + "' (length " + length + ")");
				}
			} else {
				if (verbose) {
					System.out.println("[" + this.getName() + "] Received: '" + message + "'");
				}
			}

			if (message.getJMSReplyTo() != null) {
				replyProducer.send(message.getJMSReplyTo(),
						session.createTextMessage("Reply: " + message.getJMSMessageID()));
			}

			if (transacted) {
				if ((messagesReceived % batch) == 0) {
					System.out.println("Commiting transaction for last " + batch + " messages; messages so far = "
							+ messagesReceived);
					session.commit();
				}
			} else if (ackMode == Session.CLIENT_ACKNOWLEDGE) {
				if ((messagesReceived % batch) == 0) {
					System.out.println(
							"Acknowledging last " + batch + " messages; messages so far = " + messagesReceived);
					message.acknowledge();
				}
			}

		} catch (JMSException e) {
			System.out.println("[" + this.getName() + "] Caught: " + e);
			e.printStackTrace();
		} finally {

		}
	}

	public synchronized void onException(JMSException ex) {
		System.out.println("[" + this.getName() + "] JMS Exception occured.  Shutting down client.");	
	}

	public void setAckMode(String ackMode) {
		if ("CLIENT_ACKNOWLEDGE".equals(ackMode)) {
			this.ackMode = Session.CLIENT_ACKNOWLEDGE;
		}
		if ("AUTO_ACKNOWLEDGE".equals(ackMode)) {
			this.ackMode = Session.AUTO_ACKNOWLEDGE;
		}
		if ("DUPS_OK_ACKNOWLEDGE".equals(ackMode)) {
			this.ackMode = Session.DUPS_OK_ACKNOWLEDGE;
		}
		if ("SESSION_TRANSACTED".equals(ackMode)) {
			this.ackMode = Session.SESSION_TRANSACTED;
		}
	}

	public void setClientId(String clientID) {
		this.clientId = clientID;
	}

	public void setConsumerName(String consumerName) {
		this.consumerName = consumerName;
	}

	public void setDurable(boolean durable) {
		this.durable = durable;
	}

	public void setPassword(String pwd) {
		this.password = pwd;
	}

	public void setSubject(String subject) {
		this.subject = subject;
	}

	public void setTopic(boolean topic) {
		this.topic = topic;
	}

	public void setQueue(boolean queue) {
		this.topic = !queue;
	}

	public void setTransacted(boolean transacted) {
		this.transacted = transacted;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	public void setUser(String user) {
		this.user = user;
	}

	public void setVerbose(boolean verbose) {
		this.verbose = verbose;
	}

	public void setBatch(long batch) {
		this.batch = batch;
	}

	public static void main(String[] args) {
		new ConsumerAgent().start();
	}
}
