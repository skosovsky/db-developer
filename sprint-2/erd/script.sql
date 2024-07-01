CREATE DATABASE music;

CREATE TABLE public.album (
    album_id integer PRIMARY KEY,
    title character varying(160) NOT NULL,
    artist_id integer NOT NULL
);

CREATE TABLE public.artist (
    artist_id integer PRIMARY KEY,
    name character varying(120)
);

CREATE TABLE public.playlist (
    playlist_id integer PRIMARY KEY,
    name character varying(120)
);

CREATE TABLE public.playlist_track (
    playlist_id integer NOT NULL,
    track_id integer NOT NULL
);

CREATE TABLE public.track (
    track_id integer PRIMARY KEY,
    name character varying(200) NOT NULL,
    album_id integer,
    media_type_id integer NOT NULL,
    genre_id integer,
    composer character varying(220),
    milliseconds integer NOT NULL,
    bytes integer,
    unit_price numeric(10,2) NOT NULL
);

ALTER TABLE ONLY public.track
    ADD CONSTRAINT fk_track_album_id FOREIGN KEY (album_id) REFERENCES public.album(album_id);

ALTER TABLE ONLY public.playlist_track
    ADD CONSTRAINT fk_playlist_track_track_id FOREIGN KEY (track_id) REFERENCES public.track(track_id);

ALTER TABLE ONLY public.album
    ADD CONSTRAINT fk_album_artist_id FOREIGN KEY (artist_id) REFERENCES public.artist(artist_id);

ALTER TABLE ONLY public.playlist_track
    ADD CONSTRAINT fk_playlist_track_playlist_id FOREIGN KEY (playlist_id) REFERENCES public.playlist(playlist_id);