defmodule FortKnox.Accounts do
  require Amnesia
  require Amnesia.Helper
  require Exquisite
  require Database.Account

  alias Database.Account

  def create_account(first_name, last_name, starting_balance) do
    Amnesia.transaction do
      %Account{first_name: first_name, last_name: last_name, balance: starting_balance}
      |> Account.write()
    end
  end

  def get_account(account_id) do
    Amnesia.transaction do
      Account.read(account_id)
    end
    |> case do
      %Account{} = account -> account
      _ -> {:error, :not_found}
    end
  end


  def transfer_funds(source_account_id, destination_account_id, amount) do
    Amnesia.transaction do
      accounts = {Account.read(source_account_id), Account.read(destination_account_id)}

      case accounts do
        {%Account{} = source_account, %Account{} = destination_account} ->
          if amount <= source_account.balance do
            adjust_account_balance(destination_account, amount)
            adjust_account_balance(source_account, -amount)
            :ok
          else
            {:error, :insufficient_funds}
          end

        {%Account{}, _} ->
          {:error, :invalid_destination}

        {_, _} ->
          {:error, :invalid_source}
      end
    end
  end

  def get_low_balance_accounts(min_balance) do
    Amnesia.transaction do
      Account.where(balance < min_balance)
      |> Amnesia.Selection.values()
    end
  end

  def deposit_funds(account_id, amount) do
    Amnesia.transaction do
      case Account.read(account_id) do
        %Account{} = account ->
          adjust_account_balance(account, amount)

        _ ->
          {:error, :not_found}
      end
    end
  end

  def withdraw_funds(account_id, amount) do
    Amnesia.transaction do
      case Account.read(account_id) do
        %Account{} = account ->
          if amount <= account.balance do
            adjust_account_balance(account, -amount)
          else
            {:error, :insufficient_funds}
          end

        _ ->
          {:error, :not_found}
      end
    end
  end

  defp adjust_account_balance(%Account{} = account, amount) do
    account
    |> Map.update!(:balance, &(&1 + amount))
    |> Account.write()
  end
end
