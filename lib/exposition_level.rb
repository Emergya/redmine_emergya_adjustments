class ExpositionLevel
  DEFAULT_VALUES = {
    'Leve' => {'Baja' =>'Bajo', 'Media' => 'Bajo', 'Elevada' => 'Bajo'},
    'Moderado' => {'Baja' =>'Bajo', 'Media' =>'Medio', 'Elevada' =>'Medio'},
    'Importante' => {'Baja' =>'Medio', 'Media' =>'Alto', 'Elevada' =>'Alto'}
  }

  def self.getExpositionLevelValue(impact, probability)
    if impact.present? && probability.present?
      if Setting.plugin_redmine_emergya_adjustments['expositionLevels'].present?
        return Setting.plugin_redmine_emergya_adjustments['expositionLevels'][impact][probability]
      else 
        return DEFAULT_VALUES[impact][probability]
      end
    else
      return ""
    end
  end

end
