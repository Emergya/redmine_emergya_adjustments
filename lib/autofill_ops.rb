class AutofillOps
  # Obtención del campo cobro de la factura
	def self.bill_total(facturado, iva)
		facturado.to_f * (1.0 + (iva.to_f / 100.0))
	end

  # Obtención del coste total BPO
	def self.bpo_total(anual, inicio, fin)
		dias = (fin.to_date - inicio.to_date).to_i + 1
    (anual.to_f * dias) / 365
	end

  # Cambio de moneda de facturación para facturas y proveedores
	def self.currency_exchange(moneda, original, fin)
		if moneda == 'EUR'
      euros = original.to_f
    else
      if fin.present?
        rango = CurrencyRange.get_range(moneda, fin)
      end

      if rango.present?
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
    end

    euros
	end

  # Cambio de moneda para coste anual en BPO
  def self.currency_exchange_bpo(moneda, original, inicio, fin)
    total_days = (fin.to_date - inicio.to_date).to_i + 1
    if moneda == 'EUR'
      euros = original.to_f
    elsif inicio.present? and fin.present? and fin.to_date > inicio.to_date
      remaining_days = total_days
      euros = CurrencyRange.find(:all, :conditions => ["start_date <= ? AND due_date >= ?",fin.to_date.beginning_of_day, inicio.to_date]).inject(0.0){|sum, range|
        days = ([range[:due_date].to_date, fin.to_date].min - [range[:start_date].to_date, inicio.to_date].max).to_i + 1 
        remaining_days -= days

        if range[:value].to_f > 0.0
          sum += (original.to_f * range[:value].to_f * days) / total_days
        end

        sum
      }
      valor = CurrencyRange.get_current(moneda).to_f
      if valor > 0.0
        euros += (original.to_f * valor * remaining_days) / total_days
      end
    else
      valor = CurrencyRange.get_current(moneda).to_f
      if valor > 0.0
        euros = original.to_f * valor
      else
        euros = 0.0
      end
    end

    euros
  end
end