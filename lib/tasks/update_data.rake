namespace :emergya do
	task :update_bpo_total_amount => :environment do
		if (bpo_tracker = Setting.plugin_redmine_emergya_adjustments['bpo_tracker']).present?
			Tracker.find(bpo_tracker).issues.each do |i|
				i.update_bpo_total
			end
		end
	end

	task :update_clients_total_amount => :environment do
		if (bill_tracker = Setting.plugin_redmine_emergya_adjustments['bill_tracker']).present?
			Tracker.find(bill_tracker).issues.joins(:status).where("issue_statuses.is_closed = false").each do |i|
				puts "#{i.id}"
				i.update_cobro
			end
		end
	end
end