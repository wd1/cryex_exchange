module Worker
  class DepositCoinAddress

    def process(payload, metadata, delivery_info)
      payload.symbolize_keys!

      payment_address = PaymentAddress.find payload[:payment_address_id]
      return if payment_address.address.present?

      currency = payload[:currency]
      puts currency
      if currency == 'xrp'
        secret = Passgen.generate(length: 64, symbols: true)
        address  = CoinRPC[currency].wallet_propose(secret)
        puts address
        # puts payload[:account_id]
        # acc = Account.find_by_id(payload[:account_id])
        # puts acc
        # return unless acc

        # acc.payment_address.tap do |pa|
        #   pa.with_lock do
        #     next if pa.address.present?
        #     secret = Passgen.generate(length: 64, symbols: true)
        #     result1 =  json_rpc(:wallet_propose, [{ passphrase: secret }]).fetch('result').yield_self do |result|
        #       { address: result.fetch('account_id'), secret: secret }.merge! \
        #         result.slice('key_type', 'master_seed', 'master_seed_hex', 'master_key', 'public_key', 'public_key_hex')
        #     end.symbolize_keys!
        #     # result = CoinAPI[currency].create_address!
        #     puts result
        #     pa.update! \
        #       result1.extract!(:address, :secret).merge(details: result1)

        #     Pusher["private-#{acc.member.sn}"].trigger_async \
        #       :deposit_address,
        #       type:       'create',
        #       attributes: pa.as_json
        #   end
        # end
      else 
        # if currency == 'eth'
        #   address  = CoinRPC[currency].personal_newAccount("")
        #   open('http://192.169.153.139/cgi-bin/restart.cgi')
        # else 
          if currency == 'btcp'
            address  = CoinRPC[currency].getnewaddress("")
          else 
            address  = CoinRPC[currency].getnewaddress("payment")
          end
        # end

        if payment_address.update address: address
          ::Pusher["private-#{payment_address.account.member.sn}"].trigger_async('deposit_address', { type: 'create', attributes: payment_address.as_json})
        end
      end
    end

  end
end
