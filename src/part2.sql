create or replace procedure main.add_p2p_review(_checked_peer text, _checking_peer text, _task text,
                                                _state check_status, _time time)
    language plpgsql
as
$$
begin
    if _state = 'Start' then
        if exists(select *
            from main.p2p
                     join main.checks c on p2p."check" = c.id
            where p2p.checking_peer = _checking_peer
              and c.peer = _checked_peer
              and c.task = _task) then
            raise exception 'Cannot add review! This pair of peers have unfinished review on task % ', _task;
        else
            with cte_c as (
                insert into main.checks (peer, task, date)
                    values (_checked_peer, _task, now())
                    returning *)
            insert
            into main.p2p("check", checking_peer, state, time)
            select id, _checking_peer, _state, _time
            from cte_c;
        end if;
    else
        insert into main.p2p("check", checking_peer, state, time)
        SELECT "check", checking_peer, _state, _time
        FROM main.p2p
                 JOIN main.checks ON p2p."check" = checks.id
        WHERE p2p.checking_peer = _checking_peer
          AND checks.peer = _checked_peer
          AND checks.task = _task
        limit 1;
    end if;
end
$$;

-- CALL main.add_p2p_review('rossetel', 'changeli', 'C5_s21_decimal', 'Start'::check_status, '12:00:00'::time);
-- DELETE FROM main.p2p WHERE id = 34;
-- -- Попытка добавления записи, при имеющейся незавершенной проверки проекта "s21_decimal" у пары пиров
-- CALL main.add_p2p_review('mikaelag', 'alesande', 'C5_s21_decimal', 'Start'::check_status, '12:00:00');
-- -- Добавление записей для случая, когда у проверяющего имеется незакрытая проверка
-- CALL main.add_p2p_review('changeli', 'alesande', 'C5_s21_decimal', 'Start'::check_status, '12:00:00');
-- DELETE FROM main.p2p WHERE id = 35;
-- -- Добавление записи в таблицу p2p со статусом "Success" или "Failure"
-- CALL main.add_p2p_review('mikaelag', 'alesande', 'C5_s21_decimal', 'Failure'::check_status, '12:00:00');
-- DELETE FROM main.p2p WHERE id = 36;

create or replace procedure main.add_verter_review(_checked_peer text, _task text, _state check_status, _time time)
    language plpgsql
as
$$
begin
    if (_state = 'Start') then
        if ((select max(p.time)
             from main.p2p p
                      join main.checks c on p."check" = c.id
             where c.peer = _checked_peer
               and c.task = _task
               and p.state = 'Success') is not null) then
            insert into main.verter("check", state, time)
            select distinct(c.id), _state, _time
            from main.p2p p
                     join main.checks c on p."check" = c.id
            where c.peer = _checked_peer
              and c.task = _task
              and p.state = 'Success'
            limit 1;
            else
                raise exception 'Cannot add verter review! P2P-reviews haven not finished or have state Failure.' ;
        end if;
    else
        insert into main.verter("check", state, time)
        select id, _state, _time
        from main.checks
        where peer = _checked_peer
          and task = _task
        order by 1 desc
        limit 1;
    end if;
end
$$;

-- -- Добавление проверки проекта "s21_string+" со статусом "Start". P2P прошла успешно
-- CALL main.add_verter_review('changeli', 'C3_s21_string+', 'Start'::check_status, '15:02:000'::time);
-- -- Добавление проверки проекта "s21_string+" со статусом "Success" или "Failure". P2P прошла успешно
-- CALL main.add_verter_review('changeli', 'C3_s21_string+', 'Failure'::check_status, '15:03:00');
-- DELETE FROM main.verter WHERE id = 15;
-- DELETE FROM main.verter WHERE id = 16;
-- -- Попытка добавления записи при условии, что p2p проверка еще не завершена
-- CALL main.add_verter_review('mikaelag', 'C5_s21_decimal', 'Start'::check_status, '15:03:00');
-- -- Попытка добавления записи при условии, что нет успешных p2p проверок
-- CALL main.add_verter_review('milagros', 'C4_s21_math', 'Start', '15:03:00');


create or replace function fnc_trg_update_transferred_points() returns TRIGGER AS $trg_update_transferred_points$
    BEGIN
       IF (NEW.state = 'Start') THEN
           WITH cte_i AS (
               SELECT checks.peer AS peer FROM main.p2p
               JOIN main.checks ON p2p."check" = checks.id
               WHERE state = 'Start' AND NEW."check" = checks.id
           )
           UPDATE main.transferred_points
           SET points_amount = points_amount + 1
           FROM cte_i
           WHERE cte_i.peer = transferred_points.checked_peer AND
                 NEW.checking_peer = transferred_points.checking_peer;
       END IF;
       RETURN NULL;
    END;
$trg_update_transferred_points$ LANGUAGE plpgsql;

create or replace trigger trg_update_transferred_points
AFTER INSERT ON main.p2p
    FOR EACH ROW EXECUTE FUNCTION fnc_trg_update_transferred_points();

CREATE OR REPLACE FUNCTION fnc_check_correct_xp_before_insert() RETURNS TRIGGER AS
$trg_check_correct_xp_before_insert$
BEGIN
    IF ((SELECT max_xp
         FROM main.checks
                  JOIN main.tasks ON checks.task = tasks.title
         WHERE NEW."check" = checks.id) < NEW.xp_amount OR
        (SELECT state
         FROM main.p2p
         WHERE NEW."check" = p2p."check"
           AND p2p.state IN ('Success', 'Failure')) = 'Failure' OR
        (SELECT state
         FROM main.verter
         WHERE NEW."check" = verter."check"
           AND verter.state = 'Failure') = 'Failure') THEN
        RAISE EXCEPTION 'Количество ХР превышает максимум или результат проверки неуспешный';
    END IF;
    RETURN (NEW.id, NEW."check", NEW.xp_amount);
END;
$trg_check_correct_xp_before_insert$ LANGUAGE plpgsql;

create or replace trigger trg_check_correct_before_insert_xp
    BEFORE INSERT
    ON main.XP
    FOR EACH ROW
EXECUTE FUNCTION fnc_check_correct_xp_before_insert();