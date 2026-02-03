# BDD プロジェクト仕様書

## 導入

本プロジェクトは、OCaml プログラミング言語を用いて Binary Decision Diagrams (BDD) を実装したものです。BDD は、ブール関数を効率的に表現するためのデータ構造であり、モデル検査や論理回路設計などの分野で広く利用されます。本仕様書では、BDD の型定義および提供される操作関数について詳細に記述します。

## 型定義

BDD の基本的なデータ型は以下の通りです：

- `type t = Zero | One | V of int * t * t`

  - `Zero`: ブール値 `false` を表す定数。
  - `One`: ブール値 `true` を表す定数。
  - `V (index, lo, hi)`: 変数ノード。`index` は変数番号、`lo` は変数が `false` の場合のサブ BDD、`hi` は変数が `true` の場合のサブ BDD。

この型は再帰的に定義されており、BDD のツリー構造を表現します。

## 操作テーブル

以下のテーブルは、BDD モジュールで提供されるすべての関数をまとめています。関数はカテゴリ（Base, Algebraic, Nonalgebraic, Examining）ごとに分類されています。各関数について、関数名、説明、シグネチャ（OCaml の型）、および簡単な使用例を示します。

| 関数名 | 説明 | シグネチャ | 例 |
|--------|------|------------|-----|
| `const` | ブール値から定数 BDD を生成します。 | `bool -> t` | `const true` → `One` |
| `var` | 指定された変数番号の BDD を生成します。 | `int -> t` | `var 0` → `V (0, Zero, One)` |
| `apply` | 二項演算子を BDD に適用します。 | `(bool -> bool -> bool) -> t -> t -> t` | `apply (&&) (var 0) (var 1)` → 変数 0 と 1 の AND |
| `not_` | BDD の否定を計算します。 | `t -> t` | `not_ (var 0)` → 変数 0 の否定 |
| `and_` | 二つの BDD の AND を計算します。 | `t -> t -> t` | `and_ (var 0) (var 1)` → 変数 0 と 1 の AND |
| `or_` | 二つの BDD の OR を計算します。 | `t -> t -> t` | `or_ (var 0) (var 1)` → 変数 0 と 1 の OR |
| `xor_` | 二つの BDD の XOR を計算します。 | `t -> t -> t` | `xor_ (var 0) (var 1)` → 変数 0 と 1 の XOR |
| `restrict` | 指定された変数を固定値に制限した BDD を生成します。 | `t -> int -> bool -> t` | `restrict (var 0) 0 true` → `One` |
| `compose` | 指定された変数を別の BDD で置き換えます。 | `t -> int -> t -> t` | `compose (var 0) 0 (var 1)` → 変数 0 を変数 1 で置き換え |
| `exists` | 指定された変数リストに対して存在量化を行います。 | `t -> int list -> t` | `exists (var 0) [0]` → `One` |
| `forall` | 指定された変数リストに対して全称量化を行います。 | `t -> int list -> t` | `forall (var 0) [0]` → `Zero` |
| `relprod` | 二つの BDD の関係積を計算し、指定された変数を量化します。 | `t -> t -> int list -> t` | `relprod (var 0) (var 1) [0; 1]` → `One` |
| `equal` | 二つの BDD が等しいかを判定します。 | `t -> t -> bool` | `equal (var 0) (var 0)` → `true` |
| `eval` | 指定された変数割り当てで BDD を評価します。 | `t -> int list -> bool` | `eval (var 0) [0]` → `true` |
| `satisfy` | BDD が充足可能かを判定します。 | `t -> bool` | `satisfy (var 0)` → `true` |