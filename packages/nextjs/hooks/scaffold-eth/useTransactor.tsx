import {
  TransactionReceipt,
  TransactionRequest,
  TransactionResponse,
} from "@ethersproject/abstract-provider";
import { SendTransactionResult } from "@wagmi/core";
import { Signer, ethers } from "ethers";
import { Deferrable } from "ethers/lib/utils";
import { useSigner } from "wagmi";
import deployedContracts from "~~/generated/deployedContracts";
import { getBlockExplorerTxLink, notification } from "~~/utils/scaffold-eth";

type TTransactionFunc = (
  tx:
    | Promise<SendTransactionResult>
    | Deferrable<TransactionRequest>
    | undefined,
  options?: {
    onBlockConfirmation?: (txnReceipt: TransactionReceipt) => void;
    blockConfirmations?: number;
  }
) => Promise<Record<string, any> | undefined>;

/**
 * Custom notification content for TXs.
 */
const TxnNotification = ({
  message,
  blockExplorerLink,
}: {
  message: string;
  blockExplorerLink?: string;
}) => {
  return (
    <div className={`flex flex-col ml-1 cursor-default`}>
      <p className="my-0">{message}</p>
      {blockExplorerLink && blockExplorerLink.length > 0 ? (
        <a
          href={blockExplorerLink}
          target="_blank"
          rel="noreferrer"
          className="block underline text-md"
        >
          check out transaction
        </a>
      ) : null}
    </div>
  );
};

/**
 * Runs TXs showing UI feedback.
 * @param _signer
 * @dev If signer is provided => dev wants to send a raw tx.
 */
export const useTransactor = (_signer?: Signer): TTransactionFunc => {
  let signer = _signer;
  const { data } = useSigner();
  if (signer === undefined && data) {
    signer = data;
  }

  const result: TTransactionFunc = async (tx, options) => {
    if (!signer) {
      notification.error("Wallet/Signer not connected");
      console.error("⚡️ ~ file: useTransactor.tsx ~ error ~ without Signer");
      return;
    }

    let notificationId = null;
    let errorData = null;
    let transactionResponse:
      | SendTransactionResult
      | TransactionResponse
      | undefined;
    try {
      const provider = signer.provider;
      const network = await provider?.getNetwork();

      notificationId = notification.loading(
        <TxnNotification message="Awaiting for user confirmation" />
      );
      if (tx instanceof Promise) {
        // Tx is already prepared by the caller
        transactionResponse = await tx;
      } else if (tx != null) {
        transactionResponse = await signer.sendTransaction(tx);
      } else {
        throw new Error("Incorrect transaction passed to transactor");
      }
      notification.remove(notificationId);

      const blockExplorerTxURL = network
        ? getBlockExplorerTxLink(network, transactionResponse.hash)
        : "";

      notificationId = notification.loading(
        <TxnNotification
          message="Waiting for transaction to complete."
          blockExplorerLink={blockExplorerTxURL}
        />
      );

      const transactionReceipt = await transactionResponse.wait(
        options?.blockConfirmations
      );
      notification.remove(notificationId);

      notification.success(
        <TxnNotification
          message="Transaction completed successfully!"
          blockExplorerLink={blockExplorerTxURL}
        />,
        {
          icon: "🎉",
        }
      );

      if (options?.onBlockConfirmation)
        options.onBlockConfirmation(transactionReceipt);
    } catch (error: any) {
      errorData = error;
      if (notificationId) {
        notification.remove(notificationId);
      }
      console.error("⚡️ ~ file: useTransactor.ts ~ error", error);
      errorData = errorData.error.data.data;

      const errorMsg = (iface: ethers.utils.Interface, data: string) => {
        const err = iface.parseError(data);
        const errorName = err.name;
        let errorArgs = "";
        err.errorFragment.inputs.map((i, index) => {
          errorArgs += `${i.type} ${i.name}: ${err.args[index]}, `;
        });
        if (err.errorFragment.inputs.length > 1) {
          return `${errorName}(${errorArgs.slice(0, -3)})`;
        } else {
          return `${errorName}(${errorArgs.slice(0, -2)})`;
        }
      };

      const contracts = deployedContracts[31337][0].contracts;
      for (let contract of Object.values(contracts)) {
        const abi = contract.abi.filter((item: any) => item.type === "error");
        if (abi.length > 0) {
          try {
            const iface = new ethers.utils.Interface(abi);
            const message = errorMsg(iface, errorData);
            console.error(message);
            notification.error(message);
            break;
          } catch (e) {
            console.error("Contract error not mapping", e);
          }
        }
      }
    }

    return transactionResponse;
  };

  return result;
};
