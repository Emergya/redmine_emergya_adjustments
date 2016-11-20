namespace :emergya do
	task :update_bpo_total_amount => :environment do
		if (bpo_tracker = Setting.plugin_redmine_emergya_adjustments['bpo_tracker']).present?
			Tracker.find(bpo_tracker).issues.each do |i|
				i.update_bpo_total
			end
		end
	end
end