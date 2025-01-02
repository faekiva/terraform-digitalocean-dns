export type Result<T> = Error | T;
type NotError<T> = Exclude<T, Error>;


export function Try<T>(input: () => T): Result<T> {
    try  {
        return input();
    } catch (error) {
        if (error instanceof Error) {
           return error;
        }
        throw error;
    }
}
