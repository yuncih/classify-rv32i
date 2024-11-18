# Assignment 2: Classify
## 1. abs.s
### A. Functionality
The `abs` function updates an integer to its absolute value.

- **Input**:  
  A pointer (`a0`) to an integer in memory.

- **Operation**:
  - Load the integer from memory.
  - If negative, negate it; otherwise, leave it unchanged.
  - Store the result back in memory.

- **Output**:  
  The value at the pointer is modified in place.

### B. Key Operations and Challenges

- **a. Conditional Branching**
  - **Operation**: The `bge` instruction skips negation if the value is non-negative, avoiding unnecessary work.
  - **Challenge**: Minimize computation overhead for non-negative values.
  - **Solution**: Efficient branching ensures only negative values are processed.

- **b. Negation and Memory Update**
  - **Operation**: The `neg` instruction converts negative values to positive and writes them back using `sw`.
  - **Challenge**: Perform the negation in-place without disturbing other registers.
  - **Solution**: Use of a temporary register (`t0`) isolates computations, preserving the original state.

## 2. argmax.s

### A. Functionality
The `argmax` function identifies the first index of the maximum element in an array.

- **Input**:  
  - `a0` (int*): A pointer to the first element of the array.  
  - `a1` (int): The number of elements in the array.

- **Output**:  
  - `a0` (int): The 0-based index of the first occurrence of the maximum value.

- **Preconditions**:  
  - The array must have at least one element.
  - If the array is empty (`a1 < 1`), the program terminates with exit code 36.

- **Behavior**:  
  Iterates through the array, updating the maximum value and its index whenever a new maximum is found. Returns the smallest index in case of ties.

### B. Key Operations and Challenges

- **a. Array Traversal**
  - **Operation**: Sequentially loads array elements using `lw` and advances the pointer using `addi`.
  - **Challenge**: Efficiently traverse and handle memory in a loop without accidental overwrites.
  - **Solution**: Registers (`t2` for index and `t3` for the current value) are used to maintain proper tracking.

- **b. Maximum Value Tracking**
  - **Operation**: Compares the current element (`t3`) with the current maximum (`t0`) using `bgt`. If greater, updates the maximum and its index.
  - **Challenge**: Ensure only the first occurrence of the maximum value is recorded.
  - **Solution**: Updates the index (`t1`) only when a new maximum is found, preserving the correct position for duplicates.

## 3. dot.s

### A. Functionality
The `dot` function calculates the strided dot product of two integer arrays based on the formula:

\[
\text{sum}(arr0[i \times \text{stride0}] \times arr1[i \times \text{stride1}]) \quad \text{for} \quad i = 0 \text{ to } (\text{element\_count} - 1)
\]

- **Input**:  
  - `a0`: Pointer to the first input array.  
  - `a1`: Pointer to the second input array.  
  - `a2`: Number of elements to process.  
  - `a3`: Skip distance (stride) in the first array.  
  - `a4`: Skip distance (stride) in the second array.

- **Operation**:  
  Iterates through `element_count` elements in both arrays, stepping by the provided strides. Multiplies corresponding elements from the two arrays. Accumulates the results into a sum, applying necessary negations for signed integer values.

- **Output**:  
  `a0`: The calculated dot product.

### B. Key Operations and Challenges

- **a. Loop and Indexing**
  - **Operation**:  
    - Iterates through both arrays based on `element_count`, adjusting pointers using strides.  
    - Uses efficient load (`lw`) and pointer arithmetic to access strided elements.
  - **Challenge**: Managing correct memory access with varying strides while ensuring efficient processing.
  - **Solution**:  
    - Uses register manipulation (`slli` and `add`) to compute offsets.  
    - Saves intermediate states in registers to prevent memory corruption.

- **b. Multiplication and Sign Handling**
  - **Operation**:  
    - Multiplies corresponding elements from the arrays.  
    - Adjusts for negative values using a bitwise XOR to manage sign consistency.
  - **Challenge**: Handle negative values correctly during multiplication without adding unnecessary complexity.
  - **Solution**:  
    - Isolates negation checks (`bltz` and `xori`) into modular blocks.  
    - Ensures negated results are computed efficiently before final accumulation.

## 4. matmul.s

### A. Functionality
The `matmul` function performs matrix multiplication to compute the result matrix \(D = M_0 \times M_1\).

- **Input**:  
  - `M0` (First matrix):  
    - `a0`: Pointer to the first element of the matrix.  
    - `a1`: Number of rows.  
    - `a2`: Number of columns.  
  - `M1` (Second matrix):  
    - `a3`: Pointer to the first element of the matrix.  
    - `a4`: Number of rows.  
    - `a5`: Number of columns.  
  - `D` (Output matrix):  
    - `a6`: Pointer to the storage location for the result matrix.

- **Operation**:  
  - Validates input dimensions for positivity and compatibility: `M0`’s column count must match `M1`’s row count.  
  - Iterates over rows of `M0` and columns of `M1`.  
  - Computes the dot product of each row in `M0` with each column in `M1`.  
  - Populates the result matrix `D` at the corresponding location.

- **Output**:  
  The resulting matrix `D` is stored in memory at the address specified by `a6`.

### B. Key Operations and Challenges

- **a. Outer and Inner Loops**
  - **Operation**:  
    - Iterates through each row of `M0` and each column of `M1` using nested loops.  
    - Computes each element of the result matrix `D[i][j]` as the dot product of row `i` of `M0` and column `j` of `M1`.
  - **Challenge**: Efficiently calculate addresses for accessing strided matrix elements.
  - **Solution**:  
    - Uses temporary registers and `slli` for pointer arithmetic.  
    - Saves intermediate states in registers to avoid redundant computations.

- **b. Dot Product Calculation (Helper Function)**
  - **Operation**:  
    - Computes the dot product of a row from `M0` and a column from `M1`.  
    - Manages memory accesses and element alignment dynamically based on strides.
  - **Challenge**: Efficiently perform dot product calculations for variable row and column sizes.
  - **Solution**:  
    - Leverages a helper function (`dot`) to handle the multiplication and accumulation logic.  
    - Passes pointers, stride information, and dimensions dynamically to the helper function.

## 5. relu.s

### A. Functionality
The `relu` function applies the Rectified Linear Unit (ReLU) activation in-place to an integer array. For each element `x` in the array:  
\( x = \max(0, x) \).

- **Input**:  
  - `a0`: Pointer to the integer array.  
  - `a1`: Number of elements in the array.

- **Operation**:  
  - Iterates through the array using a loop.  
  - For each element: If `x ≥ 0`, the value remains unchanged. If `x < 0`, it is replaced with 0.

- **Output**:  
  The input array is modified in place with all negative values replaced by 0.

### B. Key Operations and Challenges

- **a. Iterative Array Processing**
  - **Operation**:  
    - Loads each element of the array using `lw`.  
    - Compares the value with 0 using a `bge` instruction.  
    - Replaces negative values with 0 by storing the updated value back using `sw`.
  - **Challenge**: Ensure efficient traversal of the array and in-place modification without corrupting adjacent memory.
  - **Solution**:  
    - Incremented the array pointer (`a0`) in fixed 4-byte steps using `addi`.  
    - Managed loop control with a counter register (`t1`) for accurate iteration.

- **b. Branching Logic for ReLU**
  - **Operation**:  
    - Checks if the current element is negative.  
    - If true, sets it to 0; otherwise, leaves it unchanged.
  - **Challenge**: Minimize the overhead of conditional checks and avoid unnecessary memory writes.
  - **Solution**:  
    - Combined branching (`bge` and `j`) with selective memory writes to handle only negative values, optimizing for speed.
## 6. mul function(Take the mul function loop in read_matrix.s for example)
    li s1, 0         
    loop:
        beqz    t2, end    
        add     s1, s1, t1    
        addi    t2, t2, -1    
        j       loop         

    end:
### A. Functionality
This function computes the total number of elements by multiplying two values.
- **a. Input**
    - s2: Number of elements per iteration 
    - s3: Number of iterations
- **b. Operation**
    - Initializes s4 to 0, which will hold the total number of elements.
    - Uses a loop to add s2 to s4, s3 times.
    - The loop terminates when s3 reaches 0.
- **c. Output**
    The total number of elements (calculated as s2 * s3) is stored in s4.
### B. Key Operations and Challenges
- **a. Looping and Accumulation**
    - **Operation**:
        - A loop is used to add s2 repeatedly to s4 for s3 iterations.
        - s3 is decremented with each loop iteration.
        - The loop ends when s3 becomes 0, indicating all iterations are complete.
    - **Challenge**: Replacing the mul instruction with a custom loop-based implementation while ensuring correctness and efficiency.
    - **Solution**: The loop performs the addition of s2 to s4 instead of multiplying the values directly. This ensures that the result is accumulated correctly, and the loop provides a step-by-step breakdown of the multiplication operation.
- **b. Efficient Looping and Register Management**
    - **Operation**:
        - Uses beqz (branch if zero) to exit the loop when s3 reaches 0.
        - Registers are carefully managed to ensure the loop works without overwriting important values.
    - **Challenge**: Ensure the loop executes efficiently, especially when s3 is large, to avoid unnecessary computational overhead.
    - **Solution**:
        - The loop is minimal, with only necessary instructions to perform the accumulation.
        - The use of addi and add ensures that the loop performs simple operations, reducing potential overhead.
- **c. Handling Negative or Zero Values**
    - **Operation**: The code does not explicitly handle negative or zero values for s2 or s3. However, in typical cases, if either of these values were negative, the loop would behave unpredictably.
    - **Challenge**: Ensure that the loop can be modified to handle edge cases, such as negative or zero values, if needed.
    - **Solution**: The current implementation assumes positive values for both s2 and s3. If required, additional checks can be added to handle negative or zero values gracefully, by returning early or adjusting logic to prevent infinite loops.

