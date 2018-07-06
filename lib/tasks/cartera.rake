CF_UNIDAD_NEGOCIO_ID = 275
CF_CICLO_VIDA_ID = 18
CF_CLASIFICACION_ID = 43
CF_TECNOLOGIA_ID = 101
CF_ESTADO_ID = 120
CF_JP_ID = 276
DATE = "2018-01-01"

namespace :emergya do
	task :generate_cartera_csv, [:date] => :environment do |t, args|
		date = args[:date].present? ? args[:date].to_date : DATE.to_date

		projects = Project.joins(:bsc_info).where("DATE(bsc_project_infos.actual_start_date) <= ? AND DATE(bsc_project_infos.scheduled_finish_date) >= ?", date, date)
		headers = ["Nombre del Proyecto","Descripción","U. de Negocio","Ciclo de Vida","Clasificación (Tipología)","Tecnología","Esfuerzo","F. Inicio","F. Fin","Estado","Nombre JP","Nº integrantes del Equipo"]

		results = [headers]

		projects.each do |p|
			result = []
			result << p.name
			result << p.identifier
			result << ((field = p.custom_values.where(custom_field_id: CF_UNIDAD_NEGOCIO_ID)).present? ? field.first.value : '-')
			result << ((field = p.custom_values.where(custom_field_id: CF_CICLO_VIDA_ID)).present? ? field.first.value : '-')
			result << ((field = p.custom_values.where(custom_field_id: CF_CLASIFICACION_ID)).present? ? field.first.value : '-')
			result << ((field = p.custom_values.where(custom_field_id: CF_TECNOLOGIA_ID)).present? ? field.first.value : '-')
			result << p.time_entries.sum(:hours)
			result << p.bsc_info.actual_start_date
			result << p.bsc_info.scheduled_finish_date
			result << ((field = p.custom_values.where(custom_field_id: CF_ESTADO_ID)).present? ? field.first.value : '-')
			result << ((field = p.custom_values.where(custom_field_id: CF_JP_ID)).present? ? (field.first.value.present? ? ((user = User.find(field.first.value)).present? ? user.login : '-') : '-') : '-')
			result << p.members.count

			results << result
		end

		CSV.open("public/cartera.csv","w",:col_sep => ';',:encoding=>'UTF-8') do |file|
			results.each do |result|
				file << result
			end
		end
	end
end