set -e
psql -U admin sap <<EOSQL
CREATE TABLE Accounts (
  account_id        SERIAL PRIMARY KEY,
  account_name      VARCHAR(20),
  first_name        VARCHAR(20),
  last_name         VARCHAR(20),
  email             VARCHAR(100),
  password_hash     CHAR(64),
  portrait_image    BYTEA,
  hourly_rate       NUMERIC(9,2)
);

CREATE TABLE BugStatus (
  status            VARCHAR(20) PRIMARY KEY
);

CREATE TABLE Bugs (
  bug_id            SERIAL PRIMARY KEY,
  date_reported     DATE NOT NULL,
  summary           VARCHAR(80),
  description       VARCHAR(1000),
  resolution        VARCHAR(1000),
  reported_by       BIGINT NOT NULL,
  assigned_to       BIGINT,
  verified_by       BIGINT,
  status            VARCHAR(20) NOT NULL DEFAULT 'NEW',
  priority          VARCHAR(20),
  hours             NUMERIC(9,2),
  FOREIGN KEY (reported_by) REFERENCES Accounts(account_id),
  FOREIGN KEY (assigned_to) REFERENCES Accounts(account_id),
  FOREIGN KEY (verified_by) REFERENCES Accounts(account_id),
  FOREIGN KEY (status) REFERENCES BugStatus(status)
);

CREATE TABLE Comments (
  comment_id        SERIAL PRIMARY KEY,
  bug_id            BIGINT NOT NULL,
  -- Adjacency List
  -- parent_id         BIGINT,
  -- Path Enumeration
  path              VARCHAR(1000),
  author            BIGINT NOT NULL,
  comment_date      TIMESTAMP WITH TIME ZONE NOT NULL,
  comment           TEXT NOT NULL,
  -- Adjacency List
  -- FOREIGN KEY (parent_id) REFERENCES Comments(comment_id),
  FOREIGN KEY (bug_id) REFERENCES Bugs(bug_id),
  FOREIGN KEY (author) REFERENCES Accounts(account_id)
);

CREATE TABLE Screenshots (
  bug_id            BIGINT NOT NULL,
  image_id          BIGINT NOT NULL,
  screenshot_image  BYTEA,
  caption           VARCHAR(100),
  PRIMARY KEY (bug_id, image_id),
  FOREIGN KEY (bug_id) REFERENCES Bugs(bug_id)
);

CREATE TABLE Tags (
  bug_id            BIGINT NOT NULL,
  tag               VARCHAR(20) NOT NULL,
  PRIMARY KEY (bug_id, tag),
  FOREIGN KEY (bug_id) REFERENCES Bugs(bug_id)
);

CREATE TABLE Products (
  product_id        SERIAL PRIMARY KEY,
  product_name      VARCHAR(50)
);

CREATE TABLE BugProducts (
  bug_id            BIGINT NOT NULL,
  product_id        BIGINT NOT NULL,
  PRIMARY KEY (bug_id, product_id),
  FOREIGN KEY (bug_id) REFERENCES Bugs(bug_id),
  FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- data

INSERT INTO BugStatus (status) VALUES ('NEW');

INSERT INTO Accounts (account_name)
VALUES ('Fran'), ('Ollie'), ('Kukla');

INSERT INTO Bugs (date_reported, summary, reported_by)
VALUES (date(now()), 'The Bug', 1);

/* Adjacency List
INSERT INTO Comments (bug_id, parent_id, author, comment_date, comment)
VALUES (1, NULL, 1, now(), 'このバグの原因は何かな?'),
       (1, 1,    2, now(), 'ヌルポインターのせいじゃないかな?'),
       (1, 2,    1, now(), 'そうじゃないよ。それは確認済なんだ。'),
       (1, 1,    3, now(), '無効な入力を調べてみたら?'),
       (1, 4,    2, now(), 'そうか、バグの原因はそれだな。'),
       (1, 4,    1, now(), 'よし、じゃあチェック機能を追加してもらえるかな?'),
       (1, 6,    3, now(), '了解。修正したよ。');

WITH RECURSIVE CommentTree (comment_id, bug_id, parent_id, author, comment_date, comment, depth)
AS (
  -- 基底
  SELECT c.*, 0 AS depth FROM Comments c WHERE c.parent_id IS NULL
  UNION ALL
  -- 帰納
  SELECT c.*, ct.depth + 1 AS depth FROM CommentTree ct
  JOIN Comments c ON ct.comment_id = c.parent_id
)
SELECT * FROM CommentTree WHERE bug_id = 1;
*/

INSERT INTO Comments (bug_id, path, author, comment_date, comment)
VALUES (1, '1/',       1, now(), 'このバグの原因は何かな?'),
       (1, '1/2/',     2, now(), 'ヌルポインターのせいじゃないかな?'),
       (1, '1/2/3/',   1, now(), 'そうじゃないよ。それは確認済なんだ。'),
       (1, '1/4/',     3, now(), '無効な入力を調べてみたら?'),
       (1, '1/4/5/',   2, now(), 'そうか、バグの原因はそれだな。'),
       (1, '1/4/6/',   1, now(), 'よし、じゃあチェック機能を追加してもらえるかな?'),
       (1, '1/4/6/7/', 3, now(), '了解。修正したよ。');

SELECT * FROM Comments WHERE '1/4/6/7/' LIKE path || '%';
SELECT * FROM Comments WHERE path LIKE '1/4/%';

EOSQL
