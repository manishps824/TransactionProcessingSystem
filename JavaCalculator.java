import java.io.*;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import java.util.*;
import com.ericsson.otp.erlang.*;
public class JavaCalculator implements ActionListener 
{
	private Integer User_id;
	
	private String cause_selected;
	
	private JFrame decide;
	private JFrame jfrm;
	private JFrame popup;
	
	private JPanel pop1;

	private JButton submit_id;
	private JButton donate;
	private JButton add;
	private JButton get_causes;
	private JButton get_balance;
	private JButton select_cause;

	private JTextField MyMsgs;
	private JTextField WriteHere;
	private JTextField ID_Field;
	private JComboBox petList;
	String display = "";
	
	private static OtpErlangObject myObject;
	private static OtpNode myNode;
	private static OtpMbox myMbox;
	private static String myName;
	private static OtpErlangTuple myMsg;
	private static OtpErlangObject[] command;
	private static OtpErlangPid from;
	
    public void actionPerformed(ActionEvent e) 
    {
        if(e.getActionCommand().equals("Add to balance"))
        {
			if(WriteHere.getText().trim().length() != 0)
			{
				command = new OtpErlangObject[4];
				Integer amount = Integer.parseInt(WriteHere.getText());
				System.out.println("Trying to Add "+amount);
				
				command[0] = new OtpErlangAtom("add");
				command[1] = new OtpErlangAtom(myName+"@mps-Studio-1558");
				command[2] = new OtpErlangInt(User_id);
				command[3] = new OtpErlangInt(amount);
				OtpErlangTuple myTuple = new OtpErlangTuple(command);
				myMbox.send(from, myTuple);
				
				try
				{
					OtpErlangAtom reply;
					myObject = myMbox.receive();
					myMsg = (OtpErlangTuple) myObject;
					from = (OtpErlangPid) myMsg.elementAt(0);
					reply = (OtpErlangAtom) myMsg.elementAt(1);
					System.out.println(reply);
					MyMsgs.setText(reply.toString());
					WriteHere.setText("");
					
					cause_selected=null;
				}
				catch(Exception exp)
				{
					System.out.println(exp);
				}
			}
		}
        if(e.getActionCommand().equals("Donate"))
		{
			//done Complete
			
			
			if(WriteHere.getText().trim().length() != 0 && cause_selected!=null)
			{
				command = new OtpErlangObject[5];
				Integer amount = Integer.parseInt(WriteHere.getText());
				System.out.println("Trying to Donate "+amount);
				
				command[0] = new OtpErlangAtom("donate");
				command[1] = new OtpErlangAtom(myName+"@mps-Studio-1558");
				command[2] = new OtpErlangString(cause_selected);
				command[3] = new OtpErlangInt(User_id);
				command[4] = new OtpErlangInt(amount);
				OtpErlangTuple myTuple = new OtpErlangTuple(command);
				myMbox.send(from, myTuple);
				
				try
				{
					OtpErlangAtom reply;
					myObject = myMbox.receive();
					myMsg = (OtpErlangTuple) myObject;
					from = (OtpErlangPid) myMsg.elementAt(0);
					reply = (OtpErlangAtom) myMsg.elementAt(1);
					System.out.println(reply);
					MyMsgs.setText(reply.toString());
					WriteHere.setText("");
					
					cause_selected=null;
				}
				catch(Exception exp)
				{
					System.out.println(exp);
				}
			}
			else
			{
				if(cause_selected!=null)
				{	
					System.out.println("Please write amount first");
					MyMsgs.setText("Please write amount first");
				}
				else
				{
					System.out.println("Please select cause first");
					MyMsgs.setText("Please select cause first");
				}	
			}

		}
        if(e.getActionCommand().equals("Submit Id"))
		{
			//done Complete
			System.out.println(ID_Field.getText());
			User_id=Integer.parseInt(ID_Field.getText());

			jfrm.setVisible(true);
			decide.setVisible(false);
			
			System.out.println(User_id);
			System.out.println("blocking");
			
			command = new OtpErlangObject[3];
			command[0] = new OtpErlangAtom("check_id");
			command[1] = new OtpErlangAtom(myName+"@mps-Studio-1558");
			command[2] = new OtpErlangInt(User_id);
			
			OtpErlangTuple myTuple = new OtpErlangTuple(command);
			myMbox.send(from, myTuple);
			
			try
			{
				OtpErlangAtom reply;
				myObject = myMbox.receive();
				myMsg = (OtpErlangTuple) myObject;
				from = (OtpErlangPid) myMsg.elementAt(0);
				reply = (OtpErlangAtom) myMsg.elementAt(1);
				System.out.println(reply.toString());
				if (reply.equals(new OtpErlangAtom("error_donorNotFound")))
				{
					System.out.println("NOT FOUND");
					System.exit(0);
				}
			}
			catch(Exception exp)
			{
				System.out.println(exp);
			}	
		}
        if(e.getActionCommand().equals("Select Cause"))
		{
			// done Complete
			String selection = (String)petList.getSelectedItem();
			System.out.println(selection);
			popup.setVisible(false);
			cause_selected=selection;
			System.out.println("Cause selected is "+cause_selected);
			MyMsgs.setText("Cause selected is "+cause_selected);
		}
        if(e.getActionCommand().equals("Show Balance"))
        {
			//done Complete
			command = new OtpErlangObject[3];
			command[0] = new OtpErlangAtom("check_bal");
			command[1] = new OtpErlangAtom(myName+"@mps-Studio-1558");
			command[2] = new OtpErlangInt(User_id);
			OtpErlangTuple myTuple = new OtpErlangTuple(command);
			myMbox.send(from, myTuple);
			
			System.out.println("blocking 2");
			
			try
			{
				OtpErlangDouble reply;
				myObject = myMbox.receive();
				myMsg = (OtpErlangTuple) myObject;
				from = (OtpErlangPid) myMsg.elementAt(0);
				reply = (OtpErlangDouble) myMsg.elementAt(1);	// always return Long
				
				MyMsgs.setText("Your balance is "+ reply);
			}
			catch(Exception exp)
			{
				System.out.println(exp);
			}
		}
        if(e.getActionCommand().equals("Show Causes"))
		{
			String[] causes;
			command = new OtpErlangObject[2];
			command[0] = new OtpErlangAtom("get_causes");
			command[1] = new OtpErlangAtom(myName+"@mps-Studio-1558");
			OtpErlangTuple myTuple = new OtpErlangTuple(command);
			myMbox.send(from, myTuple);
			try
			{
				OtpErlangString reply;
				myObject = myMbox.receive();
				myMsg = (OtpErlangTuple) myObject;
				from = (OtpErlangPid) myMsg.elementAt(0);
				reply = (OtpErlangString) myMsg.elementAt(1);	// always return String
				String ans=reply.toString();
				System.out.println("##"+ans+"##");
				System.out.println("##"+ans.substring(2,ans.length()-1)+"##");
				causes= ans.substring(2,ans.length()-1).split(",");
				
			
				if(petList!=null)
				{	
					pop1.remove(petList);
				}
				petList = new JComboBox(causes);
				petList.setSelectedIndex(0);
				petList.addActionListener(this);
				pop1.add(petList);
				popup.setVisible(true);
			}
			catch(Exception exp)
			{
				System.out.println(exp);
			}
			
			
			
			
		}

    }
    
	public JavaCalculator() 
	{

		decide = new JFrame("Donor Login");
		decide.setLayout(new BorderLayout());
		decide.setSize(250, 250);
		decide.setLocationRelativeTo(null);
		decide.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		
		JPanel f1 = new JPanel();
		f1.setLayout(new GridLayout(4,3));
		f1.add(submit_id = new JButton("Submit Id"));
		f1.add(ID_Field = new JTextField(20));
		decide.add(f1);
		
		submit_id.addActionListener(this);
		decide.setVisible(true);
		
		jfrm = new JFrame("Money Lending System");
		jfrm.setLayout(new BorderLayout());
		jfrm.setSize(650, 350);
		jfrm.setLocationRelativeTo(null);
		jfrm.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		
		JPanel p1 = new JPanel();
		p1.setLayout(new GridLayout(3,8));
		p1.add(donate = new JButton("Donate"));
		p1.add(get_causes = new JButton("Show Causes"));
		p1.add(get_balance = new JButton("Show Balance"));
		p1.add(add = new JButton("Add to balance"));
		
		JPanel p2 = new JPanel();
		p2.setLayout(new GridLayout(3,8));
		p2.add(MyMsgs = new JTextField(20));
		p2.add(WriteHere = new JTextField(20));
		MyMsgs.setHorizontalAlignment(JTextField.RIGHT);
		WriteHere.setHorizontalAlignment(JTextField.RIGHT);
		MyMsgs.setEditable(false);
		WriteHere.setEditable(true);
		
		JPanel p = new JPanel();
		p.setLayout(new GridLayout());
		p.add(p2, BorderLayout.NORTH);
		p.add(p1, BorderLayout.SOUTH);

		jfrm.add(p);
		
		donate.addActionListener(this);
		get_causes.addActionListener(this);
		get_balance.addActionListener(this);
		add.addActionListener(this);
		
		
		popup = new JFrame("Cause List");
		popup.setLayout(new BorderLayout());
		popup.setSize(200, 200);
		popup.setLocationRelativeTo(null);
		popup.setDefaultCloseOperation(JFrame.HIDE_ON_CLOSE);
		
		pop1 = new JPanel();
		pop1.setLayout(new FlowLayout());
		pop1.add(select_cause = new JButton("Select Cause"));
		
		popup.add(pop1);
		select_cause.addActionListener(this);
		
		
	}
	public static void main(String[] args) throws Exception

         {
			JavaCalculator calc = new JavaCalculator();

			myNode = new OtpNode(args[0]);
			myName =args[0];
			myMbox = myNode.createMbox("counterserver");
			//~ OtpErlangObject myObject = myMbox.receive();
			//~ OtpErlangTuple myMsg = (OtpErlangTuple) myObject;
			//~ from = (OtpErlangPid) myMsg.elementAt(0);
			System.out.println(args[0]);
			System.out.println(args[1]);
			System.out.println(args[2]);
			System.out.println(args[3]);
			from = new OtpErlangPid(args[1],Integer.parseInt(args[2]),Integer.parseInt(args[3]),0);
			System.out.println(from);
			//~ OtpErlangAtom reply;
			//~ reply = (OtpErlangAtom) myMsg.elementAt(1); // should be hi
			// first contact established
			
			
/*
			OtpErlangObject myObject;

			OtpErlangTuple myMsg;

			OtpErlangPid from;

			OtpErlangString command;
			OtpErlangString donate=new OtpErlangString("donate");
			OtpErlangString donornotfound=new OtpErlangString("donate");

			Integer counter = 0;

			OtpErlangAtom myAtom = new OtpErlangAtom("ok");
			OtpErlangAtom donate = new OtpErlangAtom("ok");

			while(counter >= 0) 
			try
			{

				myObject = myMbox.receive();
				myMsg = (OtpErlangTuple) myObject;
				from = (OtpErlangPid) myMsg.elementAt(0);
				
				reply = (OtpErlangAtom) myMsg.elementAt(1);

				// here you may want to check the value of command
				System.out.println(command);
				
				if(reply.equals(donate))
				{
					System.out.println("YES");
				}	
				else if(reply.equals(donate))
					System.out.println(donate);	
				}
				OtpErlangObject[] command = new OtpErlangObject[2];
				
				command[0] = myAtom;
				command[1] = new OtpErlangInt(counter);
				
				OtpErlangTuple myTuple = new OtpErlangTuple(command);
				myMbox.send(from, myTuple);
				counter++;

			} catch(OtpErlangExit e)

                  {
*/
/*

                        break;

                  }
*/

        }
}

//public class CounterServer
//{
//}
