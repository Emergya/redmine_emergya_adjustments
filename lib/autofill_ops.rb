class AutofillOps
	def self.bill_total(facturado, iva)
		facturado.to_f * (1.0 + (iva.to_f / 100.0))
	end

	def self.bpo_total(anual, inicio, fin)
		dias = (fin.to_date - inicio.to_date).to_i + 1
    (anual.to_f * dias) / 365
	end

	def self.currency_exchange(moneda, original, fin)
		if moneda == 'EUR'
      #euros = "default"
      euros = original.to_f
    elsif fin.present?
      rango = CurrencyRange.get_range(moneda, fin)
      if rango[:value].to_f > 0.0
      	euros = original.to_f / rango[:value].to_f
      else
      	euros = 0.0
      end
    else
    	valor = CurrencyRange.get_current(moneda).to_f

    	if valor > 0.0
      	euros = original.to_f / CurrencyRange.get_current(moneda).to_f
      else
      	euros = 0.0
      end
    end

    euros
	end

  def self.currency_exchange_bpo(moneda, original, inicio, fin)
    total_days = (fin.to_date - inicio.to_date).to_i + 1
    if moneda == 'EUR'
      euros = original.to_f
    elsif inicio.present? and fin.present?
      euros = CurrencyRange.find(:all, :conditions => ["start_date <= ? AND due_date >= ?",fin.to_date, inicio.to_date]).inject(0.0){|sum, range|
        days = ([range[:due_date].to_date, fin.to_date].min - [range[:start_date].to_date, inicio.to_date].max).to_i + 1 
        total_days -= days

        if range[:value].to_f > 0.0
          sum += (days * original.to_f) / (range[:value].to_f * 365.0)
        end

        sum
      }
      valor = CurrencyRange.get_current(moneda).to_f
      if valor > 0.0
        euros += (total_days * original.to_f) / (valor * 365.0)
      end
    else
      CurrencyRange.get_current(moneda).to_f
      if valor > 0.0
        euros = (total_days * original.to_f) / (valor * 365.0)
      else
        euros = 0.0
      end
    end

    euros
  end
end