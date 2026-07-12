with source_affiliates as (
    select * from {{ source('raw_data', 'affiliate_cpa_ftd') }}
),

renamed_and_casted as (
    select
        cast(affiliate_id as string) as affiliate_id,
        cast(player_id as string) as player_id,
        trim(country) as country_code,
        cast(clicks as int64) as total_clicks,
        cast(registrations as int64) as total_registrations,
        cast(ftd as int64) as first_time_deposit,
        cast(cpa_value as numeric) as cpa_amount
    from source_affiliates
)

select * from renamed_and_casted
