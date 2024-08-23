struct Request<TPayload> {}

/// Suppose we want to support the query function to take multiple parameters
/// We can use the variadic parameter pack as follow:
@_silgen_name("query")
@discardableResult
func query<TPayload>(varArgs: Request<TPayload>...) -> [TPayload]

/// Varadic parameter allows us to pass multiple parameters of the same type
/// but it does not provide a way to constrain such that the number of responses
/// matches the number of requests. Thus, we can only add multiple parameters with
/// same TPayload type.

/// One way to solve the problem above where we can pass different TPayload types
/// and match the number of responses with the number of requests is to use tuple and
/// function overloading.
@_silgen_name("query")  // To suppress declaration without implementation warning
@discardableResult  // To suppress warning of unused result
func query<TPayload>(_ item: Request<TPayload>) -> TPayload

@_silgen_name("query")
@discardableResult
func query<TPayload1, TPayload2>(
  _ item1: Request<TPayload1>,
  _ item2: Request<TPayload2>
) -> (TPayload1, TPayload2)

@_silgen_name("query")
@discardableResult
func query<TPayload1, TPayload2, TPayload3>(
  _ item1: Request<TPayload1>,
  _ item2: Request<TPayload2>,
  _ item3: Request<TPayload3>
) -> (TPayload1, TPayload2, TPayload3)

@_silgen_name("query")
@discardableResult
func query<TPayload1, TPayload2, TPayload3, TPayload4>(
  _ item1: Request<TPayload1>,
  _ item2: Request<TPayload2>,
  _ item3: Request<TPayload3>,
  _ item4: Request<TPayload4>
) -> (TPayload1, TPayload2, TPayload3, TPayload4)

/// This approach solves the half of the problem.
/// It is not scalable and maintainable when as this approach
/// puts the arbitrary upper limit on the number of parameters.
/// what if we want to support invocation like "query(r1,r2,r3,r4,r5,r6,r7,r8,r9,r10)"?
let r1 = Request<Int>()
let r2 = Request<Double>()
let r3 = Request<String>()
let r4 = Request<Bool>()
let r5 = Request<UInt16>()

/// Error because we don't have a function that supports 6 parameters
query(r1, r2, r3, r4, r5)

/// To solve the problem above, we can use the tuple as a parameter pack.
/// All the overloaded "query" functions can be collapsed into a single function.

@_silgen_name("queryPack")
@discardableResult
func queryPack<each TPayload>(_ items: repeat Request<each TPayload>) -> (repeat each TPayload)
queryPack(r1, r2, r3, r4, r5)

/// The above solves the most of the issue but it still allows function call with 0 args.
/// "queryPack()" is still possible but we want to prevent this
/// because it is semantically meaningless to query an item without any arguments.

/// To prevent the function call with 0 args, we can use the following approach.
@_silgen_name("queryPackWithAtLeastOneArg")
@discardableResult
func queryPackWithAtLeastOneArg<TFirstPayload, each TPayload>(
  _ first: Request<TFirstPayload>,
  _ items: repeat Request<each TPayload>
) -> (TFirstPayload, repeat each TPayload)
where TFirstPayload: Equatable, repeat each TPayload: Equatable

/// Compare the following two function calls
queryPackWithAtLeastOneArg()
queryPackWithAtLeastOneArg(r1, r2, r3, r4, r5)
