use Amnesia

defdatabase Database do
  deftable(
    Account,
    [
      { :id, autoincrement },
      :first_name,
      :last_name,
      :balance
    ],
    type: :ordered_set,
    index: [:balance]
  )
end
