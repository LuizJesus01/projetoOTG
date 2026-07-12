with source_sessions as (
    select * from {{ source('raw_data', 'sessions') }}
),

renamed_and_casted as (
    select
        cast(session_id as string) as session_id,
        cast(player_id as string) as player_id,
        trim(ip) as ip_address,
        trim(device) as device_type,
        cast(timestamp as timestamp) as session_at
    from source_sessions
)

select * from renamed_and_casted
