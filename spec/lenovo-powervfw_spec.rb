require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Lenovo::PowerVFw do
  describe "Create SSH connection successfully" do
    before(:each) do
      @session = mock(Net::SSH::Connection::Session)
      Net::SSH.should_receive(:start).with('localhost', 'user', :password => 'password').and_return(@session)
      @firewall = Lenovo::PowerVFw.new('localhost', 'user', 'password')
    end
    it "should successfully establish a connection to the local ssh server " do
      @session.should_receive(:closed?).and_return(false)
      @firewall.closed?.should == false
    end

    it "should establish a connection, but disconnected" do
      @session.should_receive(:closed?).and_return(true)
      @firewall.closed?.should == true
    end

    it "should disconnect the connection which linked to the local ssh server" do
      @session.should_receive(:closed?).and_return(false)
      @firewall.closed?.should == false

      @session.should_receive(:close).and_return(true)
      @session.should_receive(:closed?).and_return(true)
      @firewall.close
      @firewall.closed?.should == true
    end

    describe "Create a packet filter" do
      it "should create a packet filter rule to deny packets" do
        cmd = 'rule add type deny name test'
        @session.should_receive(:exec!).with(cmd).and_return("")

        @firewall.add_rule('test').should == true
      end

      it "should not create an invalid packet filter" do 
        cmd = 'rule add type deny name invalid_rule'
        @session.should_receive(:exec!).with(cmd).and_return("Error")

        @firewall.add_rule('invalid_rule').should == false
      end
    end

  end

  it "should not establish a connection to the local ssh server" do
    Net::SSH.should_receive(:start).with('localhost', 'user', :password => 'password').and_raise("exception")
    client = Lenovo::PowerVFw.new('localhost', 'user', 'password')
    client.closed?.should == true
  end

end
