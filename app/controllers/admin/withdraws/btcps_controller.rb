module Admin
  module Withdraws
    class BtcpsController < ::Admin::Withdraws::BaseController
      load_and_authorize_resource :class => '::Withdraws::Btcp'

      def index
        start_at = DateTime.now.ago(60 * 60 * 24)
        @one_btcps = @btcps.with_aasm_state(:accepted).order("id DESC")
        @all_btcps = @btcps.without_aasm_state(:accepted).where('created_at > ?', start_at).order("id DESC")
      end

      def show
      end

      def update
        @btcp.process!
        redirect_to :back, notice: t('.notice')
      end

      def destroy
        @btcp.reject!
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
