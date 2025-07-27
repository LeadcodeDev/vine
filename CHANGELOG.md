## 1.6.1
- Add `schema.clone()` method to return a new instance of `VineSchema`

## 1.6.0
- Add `schema.example()` method to decorate OpenApi reporter 

## 1.5.1
- Change `Map<String, dynamic>` entry data to `dynamic` in `tryValidate`

## 1.5.0
- Added support for all schemas as a high-level entry schema
- Add benchmarks in [`Dartmark`](https://dartmark.dev) website

## 1.4.0
- Add `RegExp` property in phone validation rule

## 1.3.0
- Add missing `VineNotSameAsRule` implementation
- Implement `VineRegexRule` validation rule
- Add related [Dev.to](https://dev.to/baptiste_parmantier/validate-your-data-structures-with-vine-in-your-dart-projects-111p) article

## 1.2.0
- Move rules from handlers to dedicated classes
- Implement OpenAPI reporter

## 1.1.0
- Implement `VineBasics` validation rules
- Implement `VineGroup` validation rules
- Implement `VineDate` validation rules
- Optimize validation algorithm
- Enhance performance of the library, `~22 000 000` -> `~29 500 000` ops/sec (`+34%`)

## 1.0.0
**Initial release**

- Implement the basic functionality of the library
- Add the core validation rules
- Add the core validation functions
- Add the core validation exceptions
- Write tests for the core functionality
  - `VineAny` any
  - `VineArray` array
  - `VineBoolean` boolean
  - `VineNumber` number
  - `VineObject` object
  - `VineString` string
  - `VineEnum` enum
  - `VineUnion` union
