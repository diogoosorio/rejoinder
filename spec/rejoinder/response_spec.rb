require 'spec_helper'
require 'rejoinder/response'
require 'rejoinder/error'

RSpec.describe Rejoinder::Response do
  let(:context) { 'response' }
  let(:error_message) { 'message' }
  let(:error_code) { 1001 }
  let(:error) do
    Rejoinder::Error.new(message: error_message, code: error_code)
  end

  context 'when both an error and context are used' do
    describe '#initialize' do
      it do
        expect { described_class.new(context: context, error: error) }
          .to raise_error(ArgumentError)
      end
    end
  end

  context 'when the response is successful' do
    subject { described_class.success(context: context) }

    describe '#success?' do
      it do
        expect(subject.success?).to be true
      end
    end

    describe '#error?' do
      it do
        expect(subject.error?).to be false
      end
    end

    describe '#error!' do
      it do
        expect { subject.error! }.to_not raise_error
      end
    end

    describe '#context' do
      it do
        expect(subject.context).to eq context
      end
    end
  end

  context 'when the response is not successful' do
    subject { described_class.error(message: error_message, code: error_code) }

    describe '#success?' do
      it do
        expect(subject.success?).to be false
      end
    end

    describe '#error?' do
      it do
        expect(subject.error?).to be true
      end
    end

    describe '#error' do
      it 'should return the error message' do
        expect(subject.error.message).to eq error_message
      end

      it 'should return the error code' do
        expect(subject.error.code).to eq error_code
      end
    end

    describe '#error!' do
      it do
        expect { subject.error! }
          .to raise_error(Rejoinder::Error, error_message)
      end

      it do
        expect { subject.error! }.to raise_error do |error|
          expect(error.code).to eq error_code
        end
      end
    end
  end
end
