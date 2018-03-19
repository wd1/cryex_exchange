module Private::Withdraws
  class BtcpsController < ::Private::Withdraws::BaseController
    include ::Withdraws::Withdrawable
  end
end
