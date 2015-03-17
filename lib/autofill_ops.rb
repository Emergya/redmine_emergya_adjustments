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
      euros = "default"
    elsif fin.present?
      rango = CurrencyRange.get_range(moneda, fin)
      euros = original.to_f * rango[:value].to_f
    else
      euros = original.to_f * CurrencyRange.get_current(moneda).to_f
    end

    euros
	end
end