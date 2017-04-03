CF_SERVICIO_ID = 102
CF_REGION_ID = 166 # Renombrado a Mercado

namespace :emergya do
	task :generate_paysheet_csv => :environment do
		year = Date.today.year
		headers = ["user", "project_name", "project_identifier", "mercado", "servicio", "jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sept", "oct", "nov", "dec"]

		results = [headers]
		users = User.active

		users.each do |u|
			data = TimeEntry.where(user_id: u.id, tyear: year).group_by(&:project)

			data.each do |p, te|
				if te.present?
					result = []

					result << u.login
					result << p.name
					result << p.identifier
					result << p.custom_values.find_by(custom_field_id: CF_REGION_ID).value
					result << p.custom_values.find_by(custom_field_id: CF_SERVICIO_ID).value
					(1..12).each do |i|
						result << te.select{|e| e[:tmonth] == i}.sum(&:hours)
					end

					results << result
				end
			end
		end

		CSV.open("public/paysheet.csv","w",:col_sep => ';',:encoding=>'UTF-8') do |file|
			results.each do |result|
				file << result
			end
		end
	end
end