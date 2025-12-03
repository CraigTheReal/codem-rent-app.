Locales = Locales or {}

Locales['hu'] = {
    -- UI Szövegek
    ['ui_title'] = 'Autóbérlés',
    ['ui_bank_balance'] = 'Bank egyenleg',
    ['ui_rental_fee'] = 'Bérlési díj',
    ['ui_cost_per_interval'] = 'Költség (10 mp-enként)',
    ['ui_seats'] = 'Ülések',
    ['ui_max_speed'] = 'Max sebesség',
    ['ui_fuel_type'] = 'Üzemanyag típus',
    ['ui_rent_button'] = 'Bérlés',
    ['ui_close'] = 'Bezárás',
    ['ui_search'] = 'Keresés...',
    ['ui_all_categories'] = 'Összes kategória',
    ['ui_vehicle_details'] = 'Jármű részletek',
    ['ui_locate_vehicle'] = 'Jármű keresése',

    -- Notifikációk - Sikeres
    ['notif_rental_success'] = 'Sikeresen béreltél egy járművet! Rendszám: %s',
    ['notif_vehicle_spawned'] = 'A jármű lespawnolt! Távolság: %d méter',
    ['notif_trip_started'] = 'Utazás elkezdve! Díj: $%d / 10 másodperc',
    ['notif_trip_ended'] = 'Utazás befejezve! Teljes költség: $%d',
    ['notif_vehicle_returned'] = 'Jármű visszaadva! 30 másodperc múlva eltűnik',
    ['notif_payment_success'] = 'Fizetés sikeres: $%d',

    -- Notifikációk - Hiba
    ['notif_not_enough_money'] = 'Nincs elég pénzed! Szükséges: $%d, Van: $%d',
    ['notif_already_rented'] = 'Már béreltél járművet!',
    ['notif_no_vehicle'] = 'Nincs bérel jű járműved!',
    ['notif_spawn_failed'] = 'Nem sikerült lespawnolni a járművet! Próbáld újra',
    ['notif_too_far'] = 'Túl messze vagy a járműtől!',
    ['notif_in_vehicle'] = 'Ki kell szállnod a járműből!',
    ['notif_payment_failed'] = 'Fizetés sikertelen! Nincs elég pénzed',
    ['notif_trip_cancelled'] = 'Utazás megszakítva! Nincs elég pénzed a folytatáshoz',

    -- ox_target
    ['target_start_trip'] = 'Vezetés megkezdése',
    ['target_end_trip'] = 'Út befejezése',
    ['target_locate'] = 'Jármű helyzete',

    -- Progress Bar
    ['progress_renting'] = 'Jármű bérlése...',
    ['progress_spawning'] = 'Jármű előkészítése...',
    ['progress_starting'] = 'Utazás indítása...',
    ['progress_ending'] = 'Utazás befejezése...',
    ['progress_returning'] = 'Jármű visszaadása...',

    -- Parancsok
    ['command_rentv'] = 'Autóbérlő menü megnyitása',

    -- Kategóriák
    ['category_economy'] = 'Economy',
    ['category_intermediate'] = 'Intermediate',
    ['category_standard'] = 'Standard',
    ['category_suv'] = 'SUV',
    ['category_sport'] = 'Sport',

    -- 3D Text
    ['text_vehicle_distance'] = '%d m',
    ['text_press_e'] = '[E] Interakció',

    -- Biztonsági üzenetek
    ['security_rate_limit'] = 'Túl gyorsan próbálod! Várj egy kicsit',
    ['security_suspicious'] = 'Gyanús aktivitás észlelve! Figyelünk',
    ['security_banned'] = 'Kizárva gyanús aktivitás miatt',

    -- Egyéb
    ['blip_rental'] = 'Autóbérlés',
    ['vehicle_plate'] = 'RENT %03d',
    ['currency'] = '$%d',
    ['distance_unit'] = '%d m',
    ['speed_unit'] = '%d km/h',
}
