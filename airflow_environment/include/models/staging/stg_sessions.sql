with source as (
    select * from {{ source('raw_data', 'sessions') }}
),

renamed as (
    select
        cast(json_extract_scalar(string_field_0, '$.session_id') as string) as session_id,
        cast(json_extract_scalar(string_field_0, '$.player_id') as string) as player_id,
        cast(json_extract_scalar(string_field_0, '$.ip') as string) as ip_address,
        --cast(json_extract_scalar(string_field_0, '$.device') as string) as device_type,
        CASE 
            WHEN LOWER(cast(json_extract_scalar(string_field_0, '$.device') as string)) IN ('mobile', 'desktop', 'tablet') 
            THEN LOWER(cast(json_extract_scalar(string_field_0, '$.device') as string))
            ELSE 'other'
        END AS device_type,
        cast(json_extract_scalar(string_field_0, '$.timestamp') as timestamp) as session_at
    from source
)

select * from renamed
