require 'ncs_navigator/staff_portal'

module NcsNavigator::StaffPortal::Warehouse::ThreePointTwo
  class Enumerator
    include NcsNavigator::Warehouse::Transformers::Database
    bcdatabase :name => 'ncs_staff_portal'

    on_unused_columns :fail
    ignored_columns :id, :created_at, :updated_at, :created_by

    age_expression = '((current_date - birth_date) / 365.25)'
    produce_one_for_one(:staff, :Staff,
      :query => %Q(
        SELECT s.*,
          CASE
            WHEN yob_staff IS NOT NULL THEN to_char(yob_staff, '9999')
            ELSE
              to_char(birth_date, 'YYYY')
          END AS staff_yob,
          CASE
            WHEN age_group_code IS NOT NULL THEN age_group_code
            ELSE
              CASE
                WHEN birth_date IS NULL THEN NULL
                WHEN #{age_expression} < 18 THEN 1
                WHEN #{age_expression} < 25 THEN 2
                WHEN #{age_expression} < 35 THEN 3
                WHEN #{age_expression} < 45 THEN 4
                WHEN #{age_expression} < 50 THEN 5
                WHEN #{age_expression} < 65 THEN 6
                ELSE 7
              END
          END AS staff_age_range
        FROM staff s
        WHERE s.zipcode IS NOT NULL
      ),
      :prefix => 'staff_',
      :column_map => {
        :staff_id => :staff_id,
        :experience_code => :staff_exp,
        :zipcode => :staff_zip
      },
      :ignored_columns => %w(
        email username first_name last_name birth_date zipcode
        hourly_rate pay_type pay_amount yob_staff
        external notify numeric_id age_group_code
      )
    )

    produce_one_for_one(:staff_languages, :StaffLanguage,
      :query => %Q(
        SELECT sl.*, s.staff_id AS public_id_for_staff
        FROM staff_languages sl
          INNER JOIN staff s ON sl.staff_id = s.id
        WHERE sl.lang_code <> -5
          AND s.zipcode IS NOT NULL
      ),
      :prefix => 'staff_',
      :column_map => {
        :public_id_for_staff => :staff_id,
      },
      :ignored_columns => %w(staff_id)
    )

    # Per PO dictum, combine all "others" into one row. See #1526.
    produce_one_for_one(:staff_languages_other, :StaffLanguage,
      :query => %Q(
        SELECT a.staff_language_id, b.staff_lang_oth, b.staff_lang, b.public_id_for_staff
          FROM  (SELECT sl.staff_language_id, s.staff_id AS public_id_for_staff FROM
                staff_languages sl INNER JOIN staff s ON sl.staff_id = s.id
                WHERE sl.id  in (SELECT max(sl1.id) FROM staff_languages sl1 INNER JOIN staff s
                ON sl1.staff_id = s.id WHERE sl1.lang_code = -5 AND s.zipcode
                IS NOT NULL GROUP BY sl1.staff_id, sl1.lang_code) )
          AS a
          INNER JOIN
                (SELECT string_agg(sl.lang_other, ',') staff_lang_oth, sl.lang_code AS staff_lang,
                s.staff_id AS public_id_for_staff FROM staff_languages sl INNER JOIN staff s
                ON sl.staff_id = s.id WHERE sl.lang_code = -5 AND s.zipcode
                IS NOT NULL GROUP BY s.staff_id, sl.lang_code)
          AS b
          ON a.public_id_for_staff = b.public_id_for_staff
      ),
      :column_map => {
        :public_id_for_staff => :staff_id,
      }
    )

   produce_one_for_one(:staff_cert_trainings, :StaffCertTraining,
     :query => %Q(
       SELECT
         sct.*,
         to_char(sct.expiration_date, 'YYYY-MM-DD') AS cert_type_exp_date,
         s.staff_id AS public_id_for_staff
       FROM staff_cert_trainings sct
        INNER JOIN staff s ON sct.staff_id = s.id
       WHERE s.zipcode IS NOT NULL
     ),
     :column_map => {
       :certificate_type_code => :cert_train_type,
       :complete_code => :cert_completed,
       :background_check_code => :staff_bgcheck_lvl,
       :frequency => :cert_type_frequency,
       :comment => :cert_comment,
       :public_id_for_staff => :staff_id
     },
     :ignored_columns => %w(staff_id expiration_date)
   )

    produce_one_for_one(:staff_weekly_expenses, :StaffWeeklyExpense,
      :query => %Q(
        SELECT
          s.staff_id AS public_id_for_staff,
          swe.weekly_exp_id,
          CASE
            WHEN swe.hours IS NOT NULL THEN swe.hours
            ELSE
              COALESCE(t.staff_hours, '0.0')
            END as staff_hours,
          CASE
            WHEN swe.expenses IS NOT NULL THEN swe.expenses
            ELSE
              COALESCE(t.staff_expenses, '0.0')
            END as staff_expenses,
          CASE
            WHEN swe.miles IS NOT NULL THEN swe.miles
            ELSE
              COALESCE(t.staff_miles, '0.0')
            END as staff_miles,
          to_char(swe.week_start_date, 'YYYY-MM-DD') week_start_date,
          swe.rate,
          swe.comment
        FROM staff_weekly_expenses swe
          INNER JOIN staff s ON swe.staff_id=s.id
          LEFT JOIN (
            SELECT staff_weekly_expense_id,
              SUM(hours) staff_hours, SUM(expenses) staff_expenses, SUM(miles) staff_miles
            FROM (
              SELECT staff_weekly_expense_id, hours, expenses, miles FROM management_tasks
              UNION ALL
              SELECT staff_weekly_expense_id, hours, expenses, miles FROM data_collection_tasks
              UNION ALL
              SELECT staff_weekly_expense_id, hours, expenses, miles FROM miscellaneous_expenses
            ) all_exp
            GROUP BY staff_weekly_expense_id
          ) t ON swe.id=t.staff_weekly_expense_id
        WHERE s.zipcode IS NOT NULL
      ),
      :column_map => {
        :public_id_for_staff => :staff_id,
        :comment => :weekly_expenses_comment,
        :rate => :staff_pay
      },
      :ignored_columns => %w(hours miles expenses staff_id rate)
    )

    produce_one_for_one(:management_tasks, :StaffExpMngmntTasks,
      :query => %Q(
        SELECT
          mt.*,
          COALESCE(mt.hours, '0.0') AS mgmt_task_hrs,
          swe.weekly_exp_id AS public_id_for_staff_weekly_expenses
        FROM management_tasks mt
          INNER JOIN staff_weekly_expenses swe ON mt.staff_weekly_expense_id=swe.id
          INNER JOIN staff s ON swe.staff_id=s.id
        WHERE s.zipcode IS NOT NULL
      ),
      :prefix => 'mgmt_',
      :column_map => {
        :comment => :mgmt_task_comment,
        :public_id_for_staff_weekly_expenses => :staff_weekly_expense_id
     },
      :ignored_columns => %w(staff_weekly_expense_id hours expenses miles task_date)
    )

    produce_one_for_one(:data_collection_tasks, :StaffExpDataCllctnTasks,
      :query => %Q(
        SELECT
          dc.*,
          COALESCE(dc.hours, '0.0') AS data_coll_tasks_hrs,
          swe.weekly_exp_id AS public_id_for_staff_weekly_expenses
        FROM data_collection_tasks dc
          INNER JOIN staff_weekly_expenses swe ON dc.staff_weekly_expense_id=swe.id
          INNER JOIN staff s ON swe.staff_id=s.id
        WHERE s.zipcode IS NOT NULL
      ),
      :prefix => 'data_coll_',
      :column_map => {
        :comment => :data_coll_task_comment,
        :cases => :data_coll_task_cases,
        :public_id_for_staff_weekly_expenses => :staff_weekly_expense_id
      },
      :ignored_columns => %w(hours expenses miles task_date staff_weekly_expense_id)
    )

    ####### OUTREACH

    def self.outreach_join(table_name, id_prefix, options={})
      %Q{
        SELECT
          ot.*,
          CASE
            WHEN ot.source_id IS NOT NULL THEN ot.source_id
            ELSE 'staff_portal-' || ot.outreach_event_id || '-#{id_prefix}' || ot.id
          END AS public_id_for_this_table,
          CASE
            WHEN oe.source_id IS NOT NULL THEN oe.source_id
            ELSE 'staff_portal-' || ot.outreach_event_id
          END AS public_id_for_outreach_events
          #{', s.staff_id AS public_id_for_staff' if options[:staff]}
        FROM #{table_name} ot
          INNER JOIN outreach_events oe ON ot.outreach_event_id=oe.id
          #{'INNER JOIN staff s ON ot.staff_id=s.id' if options[:staff]}
        #{'WHERE s.zipcode IS NOT NULL' if options[:staff]}
      }
    end

    produce_one_for_one(:outreach_events, :Outreach,
      :query => %Q(
        SELECT
          CASE
            WHEN source_id IS NOT NULL THEN source_id
            ELSE 'staff_portal-' || oe.id 
          END AS outreach_event_id,
          oe.event_date,
          oe.outreach_type_code,
          oe.mode_code,
          oe.mode_other,
          oe.culture_other,
          COALESCE(oe.cost, '0.0') AS cost,
          oe.no_of_staff AS outreach_staffing,
          oe.evaluation_result_code AS outreach_eval_result,
          (COALESCE(oe.letters_quantity, '0') + COALESCE(oe.attendees_quantity, '0')) AS outreach_quantity,
          ol.language_other AS lang_other,
          2 AS outreach_incident,
          oe.tailored_code,
          CASE
            WHEN oe.tailored_code=2 AND oe.source_id IS NULL THEN 2
            ELSE COALESCE(oe.language_specific_code, -4)
            END
          AS outreach_lang1,
          CASE
            WHEN oe.tailored_code=2 AND oe.source_id IS NULL THEN 2
            ELSE COALESCE(oe.race_specific_code, -4)
            END
          AS outreach_race1,
          CASE
            WHEN oe.tailored_code=2 AND oe.source_id IS NULL THEN 2
            ELSE COALESCE(oe.culture_specific_code, -4)
            END
          AS outreach_culture1,
          CASE
            WHEN oe.tailored_code=2 AND oe.source_id IS NULL THEN -7
            ELSE COALESCE(oe.culture_code, -4)
            END
          AS outreach_culture2
        FROM outreach_events oe
         LEFT JOIN (
           SELECT outreach_event_id, language_other
           FROM outreach_languages WHERE language_other IS NOT NULL AND length(trim(language_other)) > 0
         ) ol ON oe.id=ol.outreach_event_id
      ),
      :prefix => 'outreach_'
    )

    produce_one_for_one(:outreach_languages, :OutreachLang2,
      :query => outreach_join('outreach_languages', 'L'),
      # in MDES 2.0, language other is in the main OE record for some reason
      :ignored_columns => %w(language_other outreach_event_id outreach_lang2_id source_id),
      :column_map => {
        :language_code => :outreach_lang2,
        :public_id_for_outreach_events => :outreach_event_id,
        :public_id_for_this_table => :outreach_lang2_id
      }
    )

    produce_one_for_one(:outreach_races, :OutreachRace,
      :query => outreach_join('outreach_races', 'R'),
      :ignored_columns => %w(outreach_event_id outreach_race_id source_id),
      :column_map => {
        :race_code => :outreach_race2,
        :race_other => :outreach_race_oth,
        :public_id_for_outreach_events => :outreach_event_id,
        :public_id_for_this_table => :outreach_race_id
      }
    )

    produce_records(:outreach_untailored_automatic,
      :query => %Q(
        SELECT
          CASE
            WHEN oe.source_id IS NOT NULL THEN oe.source_id
            ELSE 'staff_portal-' || oe.id || '-' || ns.ssu_id
            END
          AS outreach_event_id
        FROM outreach_events oe
         INNER JOIN outreach_segments os ON oe.id=os.outreach_event_id
         INNER JOIN ncs_ssus ns ON os.ncs_ssu_id=ns.id
        WHERE oe.tailored_code=2 AND oe.source_id IS NULL
      )
    ) do |oe_id, meta_data|
      [
        meta_data[:configuration].model(:OutreachLang2).new(
          :outreach_lang2_id => [oe_id, 'L-UT'].join('-'),
          :outreach_event_id => oe_id,
          :outreach_lang2 => '1' # English
        ),
        meta_data[:configuration].model(:OutreachRace).new(
          :outreach_race_id => [oe_id, 'R-UT'].join('-'),
          :outreach_event_id => oe_id,
          :outreach_race2 => '-7'
        )
      ]
    end

    produce_one_for_one(:outreach_targets, :OutreachTarget,
      :query => outreach_join('outreach_targets', 'T'),
      :ignored_columns => %w(outreach_event_id outreach_target_id source_id),
      :column_map => {
        :target_code => :outreach_target_ms,
        :target_other => :outreach_target_ms_oth,
        :public_id_for_outreach_events => :outreach_event_id,
        :public_id_for_this_table => :outreach_target_id
      }
    )

    produce_one_for_one(:outreach_evaluations, :OutreachEval,
      :query => outreach_join('outreach_evaluations', 'E'),
      :ignored_columns => %w(outreach_event_id outreach_event_eval_id source_id),
      :column_map => {
        :evaluation_code => :outreach_eval,
        :evaluation_other => :outreach_eval_oth,
        :public_id_for_outreach_events => :outreach_event_id,
        :public_id_for_this_table => :outreach_event_eval_id
      }
    )

    produce_one_for_one(:outreach_staff_members, :OutreachStaff,
      :query => outreach_join('outreach_staff_members', 'S', :staff => true),
      :ignored_columns => %w(outreach_event_id staff_id outreach_event_staff_id source_id),
      :column_map => {
        :public_id_for_outreach_events => :outreach_event_id,
        :public_id_for_this_table => :outreach_event_staff_id,
        :public_id_for_staff => :staff_id
      }
    )
  end
end
