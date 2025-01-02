export type Result<T> = Error | T;
type NotError<T> = Exclude<T, Error>;
export type ArrayElement<T> = T extends (infer U)[] ? U : never;

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
