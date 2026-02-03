# BDD with OCaml

（注）これは練習用プロジェクトであり、未実装の機能や非効率な実装があります。

## プロジェクト概要

このプロジェクトは、OCamlプログラミング言語を使用してBinary Decision Diagrams (BDD)を実装したものです。BDDは、ブール関数をコンパクトに表現するための強力なデータ構造で、モデル検査、論理回路設計、形式検証などの分野で広く活用されています。

## 機能

- **基本操作**: 定数や変数のBDD生成
- **代数演算**: AND, OR, XOR, NOTなどの論理演算
- **非代数演算**: 変数の制限、合成、量化（存在量化、全称量化）、関係積
- **検査機能**: BDDの等価性判定、評価、充足可能性チェック
- **効率性**: 共有構造によるメモリ最適化と高速計算

これらの機能を活用することで、ブール関数の操作を直感的に行えます。

基本的な使用例：
- 定数BDDの作成: `const true`
- 変数BDDの作成: `var 0`
- 論理演算: `and_ (var 0) (var 1)`

## 例

以下に、BDDを使用した簡単な例を示します。

### 基本的な論理演算
```ocaml
let bdd1 = var 0 in  (* 変数0 *)
let bdd2 = var 1 in  (* 変数1 *)
let and_result = and_ bdd1 bdd2 in  (* 0 AND 1 *)
let or_result = or_ bdd1 bdd2 in    (* 0 OR 1 *)
```

### 評価
```ocaml
let bdd = and_ (var 0) (var 1) in
eval bdd [0; 1]  (* 変数0=true, 変数1=true の場合の評価 *)
```

### 充足可能性チェック
```ocaml
satisfy (or_ (var 0) (not_ (var 0)))  (* 常にtrue *)
```
