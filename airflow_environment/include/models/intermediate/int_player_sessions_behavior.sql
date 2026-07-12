with sessions as (
    select * from {{ ref('stg_sessions') }}
),

-- Identificando a quantidade de IPs e dispositivos distintos que cada jogador utilizou
player_sessions_aggregated as (
    select
        player_id,
        count(distinct ip_address) as distinct_ips_count,
        count(distinct device_type) as distinct_devices_count,
        count(session_id) as total_sessions_count
    from sessions
    group by 1
)

select
    player_id,
    distinct_ips_count,
    distinct_devices_count,
    total_sessions_count
from player_sessions_aggregated
