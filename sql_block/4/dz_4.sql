
/*

Партиционировать таблицу links на 2 партиции: чётные movieId в одной партиции, нечётные в другой.

*/
CREATE TABLE LINKS_PARTED (
    MOVIEID BIGINT,
    IMDBID  VARCHAR(20),
    TMDBID  VARCHAR(20)
);



CREATE TABLE  links_parted_even0 (
    CHECK ( movieid % 2 = 0 )
) INHERITS (LINKS_PARTED);

CREATE TABLE links_parted_odd1 (
    CHECK ( movieid % 2 <> 0 )
) INHERITS (LINKS_PARTED);

CREATE RULE LINKS_PARTED_EVEN0 AS ON INSERT TO LINKS_PARTED
WHERE ( movieid % 2 = 0 )
DO INSTEAD INSERT INTO LINKS_PARTED_EVEN0 VALUES ( NEW.* );

CREATE RULE LINKS_PARTED_ODD1 AS ON INSERT TO LINKS_PARTED
WHERE ( movieid % 2 <> 0 )
DO INSTEAD INSERT INTO LINKS_PARTED_ODD1 VALUES ( NEW.* );



INSERT INTO LINKS_PARTED (
    SELECT * FROM LINKS
    WHERE movieid IN (8,10,12)
);

INSERT INTO LINKS_PARTED (
    SELECT * FROM LINKS
    WHERE movieid IN (9,11,13)
);

SELECT * FROM links_parted_even0;

SELECT * FROM links_parted_odd1;
