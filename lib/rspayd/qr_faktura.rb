module Rspayd
  class QrFaktura
    attr_reader :id, :dd, :am, :tp, :td, :sa, :msg, :on, :vs, :ks, :vii, :ini,
                :vir, :inr, :duzp, :dppd, :dt, :tb0, :t0, :tb1, :t1, :tb2, :t2,
                :ntb, :cc, :fx, :fxa, :acc, :crc32, :x_sw, :x_url, :imsg

    # platba
    attr_reader :rf, :rn, :pt, :nt, :nta, :x_vs, :x_ks

    def initialize(options)
      options = Hash[options.map { |(k, v)| [k.downcase.to_sym, v] }]
      @id    = options[:id]
      @dd    = options[:dd]
      @am    = format('%.2f', (options[:am] || options[:amount]))
      @tp    = options[:tp]
      @td    = options[:td]
      @sa    = options[:sa]
      @imsg  = options[:imsg]
      @msg   = options[:msg]
      @on    = options[:on]
      @vs    = options[:vs]
      @ks    = options[:ks]
      @vii   = options[:vii]
      @ini   = options[:ini]
      @vir   = options[:vir]
      @inr   = options[:inr]
      @duzp  = options[:duzp]
      @dppd  = options[:dppd]
      @dt    = options[:dt]
      @tb0   = '%.2f' % options[:tb0] if options[:tb0]
      @t0    = '%.2f' % options[:t0]  if options[:t0]
      @tb1   = '%.2f' % options[:tb1] if options[:tb1]
      @t1    = '%.2f' % options[:t1]  if options[:t1]
      @tb2   = '%.2f' % options[:tb2] if options[:tb2]
      @t2    = '%.2f' % options[:t2]  if options[:t2]
      @ntb   = options[:ntb]
      @cc    = options[:cc] || 'CZK'
      @fx    = options[:fx]
      @fxa   = options[:fxa]
      @acc   = options[:acc] || options[:iban]
      @crc32 = options[:crc32]
      @x_sw  = options[:x_sw] || options[:'x-sw']
      @x_url = options[:x_url]
    end

    def to_qr_invoice
      out = []
      out << 'SID*1.0'
      %i[id dd tp am msg on vs ks vii ini
         inr vir duzp dppd dt tb0 t0 tb1 t1 tb2 t2
         ntb cc fx fxa td sa acc crc32 x_sw x_url].each do |key|
        out << "#{key.to_s.upcase.gsub(/_/, '-')}:#{send(key)}" unless send(key).nil?
      end
      out.join('*') + '*'
    end

    def to_qr_payment
      @x_vs = @vs
      @x_ks = @ks
      out = []
      out << 'SPD*1.0'
      %i[am msg x_vs x_ks dt cc acc rf rn pt crc32 nt nta].each do |key|
        out << "#{key.to_s.upcase.gsub(/_/, '-')}:#{send(key)}" unless send(key).nil?
      end
      inv = %i[id imsg dd tp on vii ini inr vir duzp dt dppd tb0 t0 tb1 t1 tb2 t2 ntb fx fxa td sa x_sw x_url].collect do |key|
        next if send(key).nil?

        key_name = key == :imsg ? :msg : key

        "#{key_name.to_s.upcase.gsub(/_/, '-')}:#{send(key)}"
      end.compact.join('%2A')
      out << "X-INV:SID%2A1.0%2A#{inv}"
      out.join('*') + '*'
    end
  end
end
