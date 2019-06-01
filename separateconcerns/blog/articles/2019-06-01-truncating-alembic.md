% Truncating an Alembic migrations history
% Pierre 'catwell' Chapuis
% 2019-06-01 19:00:00

    ::description::
    How to truncate an Alembic migrations history in projects that use Flask-Migrate.


In projects that use SQLAlchemy and [Alembic](https://alembic.sqlalchemy.org) via [Flask-Migrate](https://flask-migrate.readthedocs.io), you may want to truncate the migrations history. By that I mean: rewrite all the migrations up to some point as a single initial migration, to avoid replaying them every single time you create a new database instance. Of course, you only want to do that if you have already migrated all your database instances at least up to that point.

As far as I know, there is no Alembic feature to do this automatically. However, I found a way to avoid having to write the migration by hand. Here is an example of how you can achieve this with a project using Git, PostgreSQL, and [environment variables for configuration](https://12factor.net).

First, checkout a commit of your project where the first migration you want to keep is the current migration, and create a temporary branch. Then, take a note of the ID of that migration (for instance `abcd12345678`), delete the whole `migrations` directory and reinitialize Alembic.

    git checkout $my_commit
    git checkout -b tmp-alembic
    rm -rf migrations
    flask db init

At this point, using Git, revert changes to files where you should keep your changes, such as `script.py.mako` and `env.ini`. Then, create a temporary empty database to work with.

    git checkout migrations/script.py.mako
    git checkout migrations/env.py
    createdb -T template0 my-temp-db

Now create the initial migration that corresponds to your model, with the ID that you noted previously, e.g.:

    MY_DATABASE_URI="postgresql://postgres@localhost/my-empty-db" \
        flask db migrate --rev-id abcd12345678

Finally, you can delete the temporary database, commit your changes to your temporary branch, merge it into your main development branch and delete it:

    dropdb my-empty-db
    git commit
    git checkout dev
    git merge tmp-alembic
    git branch -D tmp-alembic
