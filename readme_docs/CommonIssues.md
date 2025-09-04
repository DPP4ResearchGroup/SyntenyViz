# Common Issues in SyntenyViz

Below are some frequently encountered issues when using the SyntenyViz package, along with debugging tips and solutions.

---

## 1. Package Not Loading or Not Found

**Symptoms:**  
- Error: `there is no package called 'SyntenyViz'`
- Error: `could not find function ...`

**Debug Steps:**
- Ensure you have installed the package:  
  ```r
  devtools::install()
  ```
- If developing, use:  
  ```r
  devtools::load_all()
  ```
- Check your working directory is set to the package root.

---

## 2. Missing Dependencies

**Symptoms:**  
- Error messages about missing packages (e.g., `there is no package called 'orthogene'`).

**Debug Steps:**
- Run the dependency check function:  
  ```r
  check_dependencies()
  ```
- Manually install missing packages:  
  ```r
  install.packages("orthogene")
  BiocManager::install("GenomicRanges")
  ```

---

## 3. `getOrthHomolog` Fails or Returns Empty

**Symptoms:**  
- Error: `object 'getOrthHomolog' not found`
- Function returns `NULL` or empty data frame.

**Debug Steps:**
- Make sure the package is loaded (see above).
- Check that you are using valid species names and gene IDs.
- Use the debug mode for more information:  
  ```r
  getOrthHomolog("mouse", "ENSG00000139618", debug = TRUE)
  ```
- Review the console output for specific error messages.

---

## 4. Invalid Input Types

**Symptoms:**  
- Error: `gene_id must be a character string`
- Error: `invalid gene_id_type`

**Debug Steps:**
- Ensure all function arguments are of the correct type (e.g., character strings for gene IDs).
- Refer to the function documentation for accepted values.

---

## 5. Plotting or Visualization Issues

**Symptoms:**  
- Plots do not appear.
- Error: `could not find function "plotSynteny"`

**Debug Steps:**
- Confirm that all plotting dependencies (e.g., Gviz, grid) are installed.
- Check that the plotting function is exported and loaded.
- Try running a minimal example from the documentation.

---

## 6. General Debugging Tips

- Use the provided debugging script:  
  ```r
  source("debug_package.R")
  main_debug()
  ```
- Check the [Debugging Guide](DEBUGGING_GUIDE.md) for more detailed instructions.
- If you encounter a new issue, try to isolate it with a minimal reproducible example.

---

If your issue is not listed here, please consult the [Issue Tracker](Issues.md) or open a new issue with detailed information.

