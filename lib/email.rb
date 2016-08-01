module Email
  class << self
    def parse(str, options = {})
      str = NKF.nkf('-WwM', str).gsub(/\n/, '')
      Mail::Address.new(str)
    rescue Mail::Field::ParseError => e
      if options[:raise_errors]
        raise e
      else
        nil
      end
    end

    def parse_list(str, options = {})
      str = str.split(/[\t\r\n]+/).join(', ')
      str = NKF.nkf('-WwM', str).gsub(/\n/, '')
      Mail::AddressList.new(str).addresses
    rescue Mail::Field::ParseError => e
      if options[:raise_errors]
        raise e
      else
        []
      end
    end

    def encode_list(str, encoding = 'utf-8')
      addresses = parse_list(str)
      enccode_addresses(addresses, encoding)
    end

    def encode_address(address, encoding = 'utf-8')
      if address.display_name.present?
        opt = encoding.downcase == 'iso-2022-jp' ? '-WjM' : '-WwM'
        display_name = NKF.nkf(opt, quote_phrase(address.display_name))
        "#{display_name} <#{address.address}>"
      else
        address.address
      end
    end

    def encode_addresses(addresses, encoding = 'utf-8')
      addresses.map do |addr|
        encode_address(addr, encoding)
      end.join(', ')
    end

    def valid_email?(email)
      email =~ /\A[a-zA-Z0-9!"#\$%&'\*\+\-\/=\?\^_`\{\|\}~\.]+@[a-zA-Z0-9\-\.]+\Z/
    end

    def quote_phrase(str)
      unquoted = Mail::Encodings.unquote(str)
      if unquoted =~ /[#{Regexp.escape(%Q|()<>[]:;@\\,."|)}[:cntrl:]]/
        Mail::Encodings.quote_phrase(unquoted)
      else
        unquoted
      end
    end

    def unquote(str)
      Mail::Encodings.unquote(str)
    end
  end
end
