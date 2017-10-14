require 'spec_helper'
require 'rejoinder/handler'
require 'rejoinder/error'
require 'rejoinder/response'

RSpec.describe Rejoinder::Handler do
  context 'when the response is successful' do
    let(:context) { 'success!' }
    let(:response) { Rejoinder::Response.new(context: context) }

    subject { described_class.new(response: response) }

    describe '#initialize' do
      it 'yields control to the handler when one is provided' do
        expect { |handler|
          described_class.new(response: response, &handler)
        }.to yield_with_args(context)
      end
    end

    describe '#on_success' do
      it 'evaluates immediately if the evaluate parameter is true' do
        expect { |handler|
          subject.on_success(evaluate: true, &handler)
        }.to yield_with_args(context)
      end

      it 'raises an error when two handlers are registered' do
        expect { |handler|
          subject.on_success(&handler)
                 .on_success(&handler)
        }.to raise_error(ArgumentError)
      end

      it 'raises an error if no handler is provided' do
        expect { subject.on_success }.to raise_error(ArgumentError)
      end
    end

    describe '#evaluate' do
      it "doesn't yield control to any error block" do
        expect { |handler|
          subject.on_error(&handler)
                 .on_error(with_code: 1, &handler)
                 .on_error(with_code: 2, &handler)
                 .evaluate
        }.not_to yield_control
      end

      it 'yields control to the success block' do
        expect { |handler|
          subject.on_error { raise }
                 .on_success(&handler)
                 .evaluate
        }.to yield_with_args(context)
      end

      it 'returns the response context if no handler is registered' do
        expect(subject.evaluate).to eq(context)
      end
    end
  end

  context 'when the response has an error' do
    let(:response) { Rejoinder::Response.new(error: error) }
    let(:error_code) { 100 }
    let(:error_message) { 'my error' }
    let(:error) {
      Rejoinder::Error.new(code: error_code, message: error_message)
    }

    subject { described_class.new(response: response) }

    describe '#initialize' do
      it 'raises an error if a block is passed to the constructor' do
        expect {
          handler = ->() { 'something' }
          described_class.new(response: response, &handler)
        }.to raise_error(error)
      end
    end

    describe '#on_error' do
      it 'raises an error if two handlers are registered for the same code' do
        expect { |handler|
          subject.on_error(with_error: error_code, &handler)
                 .on_error(with_error: error_code, &handler)
        }.to raise_error(ArgumentError)
      end

      it 'raises an error if two global error handlers are registered' do
        expect { |handler|
          subject.on_error(&handler)
                 .on_error(&handler)
        }.to raise_error(ArgumentError)
      end

      it 'raises an error if no handler is provided' do
        expect { subject.on_error }.to raise_error(ArgumentError)
      end
    end

    describe '#evaluate' do
      it "doesn't yield control to the success block" do
        expect { |handler|
          subject.on_error { 'error' }
                 .on_success(&handler)
                 .evaluate
        }.not_to yield_control
      end

      context "when there's a specific error handler for the code" do
        it 'yields control to the most specific handler' do
          expect { |handler|
            subject.on_error { raise }
                   .on_error(with_code: error_code, &handler)
                   .on_success { raise }
                   .evaluate
          }.to yield_with_args(error)
        end

        it "doesn't yield control to the generic error handler" do
          expect { |handler|
            subject.on_error(&handler)
                   .on_error(with_code: error_code) { 'something' }
                   .on_success { raise }
                   .evaluate
          }.not_to yield_control
        end
      end

      context "when there's no specific error handler for the code" do
        it 'yields control to the generic error handler' do
          expect { |handler|
            subject.on_error(&handler)
                   .on_error(with_code: 0) { raise }
                   .on_success { raise }
                   .evaluate
          }.to yield_with_args(error)
        end
      end

      it "raises an error if there's no error handler defined" do
        expect { subject.evaluate }.to raise_error(error)
      end
    end
  end
end
