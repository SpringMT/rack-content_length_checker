require 'spec_helper'
require 'timecop'
require 'logger'

describe Rack::ContentLengthChecker do
  app = lambda { |env|
    [200, {'Content-Type' => 'text/plain'}, ["Hello, World!"]]
  }

  after do
    Timecop.return
  end
  let(:capture_logger) do
    logger = ::Logger.new($stdout)
    logger.formatter = proc{|severity, datetime, progname, message|
       "#{severity}\t#{message}\n"
    }
    logger
  end

  context 'confirm to Rack::Lint' do
    subject do
      Rack::Lint.new( Rack::ContentLengthChecker.new(app) )
    end
    it do
      response = Rack::MockRequest.new(subject).get('/')
      expect(response.successful?).to be_truthy
      expect(response.body).to eq 'Hello, World!'
    end
  end

  context 'warnのみを設定した場合' do
    context 'lengthのみ' do
      context 'WARNより小さい' do
        context 'response' do
          subject do
            Rack::Lint.new( Rack::ContentLengthChecker.new(app, warn: {length: 100}) )
          end
          it do
            response = Rack::MockRequest.new(subject).post('/', {params: {test: 123}})
            expect(response.successful?).to be_truthy
            expect(response.body).to eq 'Hello, World!'
          end
        end
        context 'キャプチャ' do
          subject do
            Rack::Lint.new( Rack::ContentLengthChecker.new(app, warn: {length: 100}, logger: capture_logger) )
          end
          it do
            expect { Rack::MockRequest.new(subject).post('/', {params: {test:123}}) }.to output('').to_stdout
          end
        end
      end

      context 'WARNの値より大きい' do
        context 'loggerを指定しない' do
          subject do
            Rack::Lint.new( Rack::ContentLengthChecker.new(app, warn: {length: 2}) )
          end
          it do
            response = Rack::MockRequest.new(subject).post('/', {params: {test: 123}})
            expect(response.successful?).to be_truthy
            expect(response.body).to eq 'Hello, World!'
          end
        end
        context 'キャプチャ' do
          subject do
            Rack::Lint.new( Rack::ContentLengthChecker.new(app, warn: {length: 2}, logger: capture_logger) )
          end
          it do
            expect { Rack::MockRequest.new(subject).post('/', {params: {test:123}}) }.to output("WARN\tremote_addr:\tmethod:POST\turi:\tmsg:Request Entity Too Large : 8 bytes\n").to_stdout
          end
        end
      end
    end
    context 'is_error' do
      subject do
        Rack::Lint.new( Rack::ContentLengthChecker.new(app, warn: {length: 2, is_error: true}) )
      end
      it do
        response = Rack::MockRequest.new(subject).post('/', {params: {test: 123}})
        expect(response.status).to eq 413
        expect(response.body).to eq 'Request Entity Too Large : 8 bytes'
      end
    end
  end

  context 'fatalの値のみ設定した場合' do
    context 'lengthのみ' do
      context 'FATALより小さい' do
        context 'response' do
          subject do
            Rack::Lint.new( Rack::ContentLengthChecker.new(app, fatal: {length: 100}) )
          end
          it do
            response = Rack::MockRequest.new(subject).post('/', {params: {test: 123}})
            expect(response.successful?).to be_truthy
            expect(response.body).to eq 'Hello, World!'
          end
        end
        context 'キャプチャ' do
          subject do
            Rack::Lint.new( Rack::ContentLengthChecker.new(app, fatal: {length: 100}, logger: capture_logger) )
          end
          it do
            expect { Rack::MockRequest.new(subject).post('/', {params: {test:123}}) }.to output('').to_stdout
          end
        end
      end

      context 'FATALの値より大きい' do
        context 'response' do
          subject do
            Rack::Lint.new( Rack::ContentLengthChecker.new(app, fatal: {length: 2}) )
          end
          it do
            response = Rack::MockRequest.new(subject).post('/', {params: {test: 123}})
            expect(response.successful?).to be_truthy
            expect(response.body).to eq 'Hello, World!'
          end
        end
        context 'キャプチャ' do
          subject do
            Rack::Lint.new( Rack::ContentLengthChecker.new(app, fatal: {length: 2}, logger: capture_logger) )
          end
          it do
            expect { Rack::MockRequest.new(subject).post('/', {params: {test:123}}) }.to output("FATAL\tremote_addr:\tmethod:POST\turi:\tmsg:Request Entity Too Large : 8 bytes\n").to_stdout
          end
        end
      end
    end
    context 'is_error' do
      subject do
        Rack::Lint.new( Rack::ContentLengthChecker.new(app, fatal: {length: 2, is_error: true}) )
      end
      it do
        response = Rack::MockRequest.new(subject).post('/', {params: {test: 123}})
        expect(response.status).to eq 413
        expect(response.body).to eq 'Request Entity Too Large : 8 bytes'
      end
    end
  end

  context 'warnとfatalの両方が設定されている' do
    context 'alert無し' do
      subject do
        Rack::Lint.new( Rack::ContentLengthChecker.new(app, warn: {length: 5}, fatal: {length: 10}) )
      end
      it do
        response = Rack::MockRequest.new(subject).post('/', {params: {a: 1}})
        expect(response.successful?).to be_truthy
        expect(response.body).to eq 'Hello, World!'
      end
    end

    context 'warn' do
      context 'response' do
        subject do
          Rack::Lint.new( Rack::ContentLengthChecker.new(app, warn: {length: 5}, fatal: {length: 10}) )
        end
        it do
          response = Rack::MockRequest.new(subject).post('/', {params: {a: 123}})
          expect(response.successful?).to be_truthy
          expect(response.body).to eq 'Hello, World!'
        end
      end
      context 'キャプチャ' do
        subject do
          Rack::Lint.new( Rack::ContentLengthChecker.new(app, warn: {length: 5}, fatal: {length: 10}, logger: capture_logger) )
        end
        it do
          expect { Rack::MockRequest.new(subject).post('/', {params: {a: 123}}) }.to output("WARN\tremote_addr:\tmethod:POST\turi:\tmsg:Request Entity Too Large : 5 bytes\n").to_stdout
        end
      end
    end

    context 'fatal' do
      context 'response' do
        subject do
          Rack::Lint.new( Rack::ContentLengthChecker.new(app, warn: {length: 5}, fatal: {length: 10}) )
        end
        it do
          response = Rack::MockRequest.new(subject).post('/', {params: {a: 12345678}})
          expect(response.successful?).to be_truthy
          expect(response.body).to eq 'Hello, World!'
        end
      end
      context 'キャプチャ' do
        subject do
          Rack::Lint.new( Rack::ContentLengthChecker.new(app, warn: {length: 5}, fatal: {length: 10}, logger: capture_logger) )
        end
        it do
          expect { Rack::MockRequest.new(subject).post('/', {params: {a: 12345678}}) }.to output("FATAL\tremote_addr:\tmethod:POST\turi:\tmsg:Request Entity Too Large : 10 bytes\n").to_stdout
        end
      end
    end
  end


  context 'warnのlenghtがfatalのlenghtより大きい場合は例外となる' do
    subject do
      Rack::Lint.new(  Rack::ContentLengthChecker.new(app, warn: {length: 10}, fatal: {length: 5}) )
    end
    it do
      expect { subject }.to raise_error(ArgumentError, 'Warn length is smaller than fatal one.')
    end
  end

end
