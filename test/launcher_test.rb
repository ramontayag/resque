require 'test_helper'
require 'resque/launcher'
require 'ostruct'

describe "Resque::Launcher" do
  include Test::Unit::Assertions

  describe '.start' do
    describe 'when environment variable PIDFILE is present' do
      before do
        ENV['PIDFILE'] = 'tmp/test.pid'
        ENV['QUEUE'] = '*'
      end

      after do
        ENV.delete('PIDFILE')
        ENV.delete('QUEUE')
        FileUtils.rm('tmp/test.pid')
        Resque::Worker.any_instance.unstub(:work)
      end

      it 'writes a pid file' do
        Resque::Worker.any_instance.stubs(:work).returns(true)
        Resque::Launcher.start
        File.exists?('tmp/test.pid').must_equal true
      end
    end

    # TODO: How to do a should_receive with MiniTest?
    describe 'when environment variable BACKGROUND is present' do
      it 'sets Process to launch as daemon'
    end

    describe 'when environment variable INTERVAL is present' do
      it 'sets the interval to INTERVAL'
    end

    describe 'when environment variable INTERVAL is not present' do
      it 'sets the interval to 5'
    end

    it 'starts a resque worker'
  end
end
