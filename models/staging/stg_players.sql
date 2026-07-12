with source_players as (
    select * from {{ source('raw_data', 'players') }}
),

renamed_and_casted as (
    select
        -- Garante que o ID seja tratado de forma consistente como texto ou número
        cast(player_id as string) as player_id,
        
        -- Limpeza básica de strings
        trim(email) as player_email,
        trim(city) as player_city,
        
        -- Garante a tipagem correta de data/timestamp para análises temporais
        cast(created_at as timestamp) as account_created_at

    from source_players
)

select * from renamed_and_casted
