context("id")


# use_id ------------------------------------------------------------------
test_that("use_id works", {
  mtcars_id <- mtcars %>% use_id()

  expect_true(is_keyed_df(mtcars_id))
  expect_identical(names(keys(mtcars_id)), ".id")
  expect_identical(keys(mtcars_id)[[1]], seq_len(nrow(mtcars)))
})


# compute_id_name ---------------------------------------------------------
test_that("compute_id_name works", {
  expect_equal(
    compute_id_name(c("id", ".ID", "_id", "a.id", "..id", ".id12")),
    ".id"
  )
  expect_equal(compute_id_name(c(".id")), ".id1")
  expect_equal(compute_id_name(c(".id1")), ".id")
  expect_equal(compute_id_name(c(".id11")), ".id")
  expect_equal(compute_id_name(c(".id", ".id1")), ".id11")
})


# add_id ------------------------------------------------------------------
test_that("add_id works", {
  input_1 <- data.frame(id = 1, .id = 2, a = "3")
  output_ref_1 <- data.frame(.id1 = 1L, id = 1, .id = 2, a = "3")

  expect_equal(add_id(input_1), output_ref_1)

  input_2 <- tibble(id = 1, .id = 2, a = "3")
  output_ref_2 <- tibble(.id1 = 1L, id = 1, .id = 2, a = "3")

  expect_equal(add_id(input_2), output_ref_2)
})

test_that("add_id works on grouped_df", {
  input_1 <- mtcars
  output_1 <- input_1 %>% group_by(vs, am) %>% add_id()
  output_ref_1 <- input_1
  output_ref_1[[".id"]] <- seq_len(nrow(input_1))
  output_ref_1 <- select(output_ref_1, .id, everything()) %>%
    group_by(vs, am)

  # In case of raw data frame input to `group_by()`, results may not be
  # identical due to strict behavior of 'tibble' with respect to row names
  expect_equal(output_1[[".id"]], output_ref_1[[".id"]])
  expect_equal(colnames(output_1), colnames(output_ref_1))

  input_2 <- as_tibble(mtcars)
  output_2 <- input_2 %>% group_by(vs, am) %>% add_id()
  output_ref_2 <- input_2
  output_ref_2[[".id"]] <- seq_len(nrow(input_2))
  output_ref_2 <- select(output_ref_2, .id, everything()) %>%
    group_by(vs, am)

  expect_identical(output_2, output_ref_2)
})


# key_by_id ---------------------------------------------------------------
test_that("key_by_id works", {
  input_1 <- tibble(id = 1, .id = 2, a = "3")
  output_1 <- key_by_id(input_1)
  output_ref <- tibble(.id1 = 1L, id = 1, .id = 2, a = "3") %>%
    key_by(.id1)

  expect_identical(output_1, output_ref)

  input_2 <- tibble(id = 1, .id = 2, a = "3", .id1 = 2L) %>%
    key_by(.id1, .exclude = TRUE)
  output_2 <- key_by_id(input_2)

  expect_identical(output_2, output_ref)
})

test_that("key_by_id works on grouped_df", {
  input_1 <- mtcars
  output_1 <- input_1 %>% group_by(vs, am) %>% key_by_id()
  output_ref_1 <- input_1
  output_ref_1[[".id"]] <- seq_len(nrow(input_1))
  output_ref_1 <- output_ref_1 %>%
    select(.id, everything()) %>%
    key_by(.id) %>%
    group_by(vs, am)

  # In case of raw data frame input to `group_by()`, results may not be
  # identical due to strict behavior of 'tibble' with respect to row names
  expect_equal(output_1[[".id"]], output_ref_1[[".id"]])
  expect_equal(colnames(output_1), colnames(output_ref_1))
  expect_equal(keys(output_1), keys(output_ref_1))

  input_2 <- as_tibble(mtcars)
  output_2 <- input_2 %>% group_by(vs, am) %>% key_by_id()
  output_ref_2 <- input_2
  output_ref_2[[".id"]] <- seq_len(nrow(input_2))
  output_ref_2 <- output_ref_2 %>%
    select(.id, everything()) %>%
    key_by(.id) %>%
    group_by(vs, am)

  expect_identical(output_2, output_ref_2)

  input_3 <- mtcars
  output_3 <- input_3 %>%
    assign_keys(tibble(.id = 2:(nrow(input_3) + 1))) %>%
    group_by(vs, am) %>%
    key_by_id()
  output_ref_3 <- input_3 %>%
    add_id() %>%
    group_by(vs, am) %>%
    key_by(.id, .exclude = FALSE)

  # In case of raw data frame input to `group_by()`, results may not be
  # identical due to strict behavior of 'tibble' with respect to row names
  expect_equal(output_1[[".id"]], output_ref_1[[".id"]])
  expect_equal(colnames(output_1), colnames(output_ref_1))
  expect_equal(keys(output_1), keys(output_ref_1))
})

test_that("key_by_id handles .add and .exclude arguments", {
  input <- tibble(id = 1, .id = 2, a = "3", .id1 = 2L) %>%
    key_by(.id1, .exclude = TRUE)
  output_1 <- key_by_id(input, .add = FALSE, .exclude = FALSE)
  output_ref_1 <- tibble(.id1 = 1L, id = 1, .id = 2, a = "3") %>%
    key_by(.id1, .add = FALSE, .exclude = FALSE)

  expect_identical(output_1, output_ref_1)

  output_2 <- key_by_id(input, .add = TRUE, .exclude = FALSE)
  output_ref_2 <- tibble(.id11 = 1L, id = 1, .id = 2, a = "3", .id1 = 2L) %>%
    key_by(.id1, .exclude = TRUE) %>%
    key_by(.id11, .add = TRUE, .exclude = FALSE)

  expect_identical(output_2, output_ref_2)

  output_3 <- key_by_id(input, .add = FALSE, .exclude = TRUE)
  output_ref_3 <- tibble(.id1 = 1L, id = 1, .id = 2, a = "3") %>%
    key_by(.id1, .add = FALSE, .exclude = TRUE)

  expect_identical(output_3, output_ref_3)

  output_4 <- key_by_id(input, .add = TRUE, .exclude = TRUE)
  output_ref_4 <- tibble(.id11 = 1L, id = 1, .id = 2, a = "3", .id1 = 2L) %>%
    key_by(.id1, .id11, .exclude = TRUE)

  expect_identical(output_4, output_ref_4)
})
