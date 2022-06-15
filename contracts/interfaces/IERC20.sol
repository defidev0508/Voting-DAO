// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev Интерфейс стандарта ERC-20.
 */
interface IERC20 {
    /**
     * @notice Возвращает имя токена.
     * @return Имя.
     */
    function name() external view returns (string memory);

    /**
     * @notice Возвращает символ токена.
     * @return Символ.
     */
    function symbol() external view returns (string memory);

    /**
     * @notice Возвращает десятичный разряд токена.
     * @return Десятичный разряд.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Возвращает количество существующих токенов.
     * @return Количество существующих токенов.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Возвращает количество токенов, принадлежащих `account`.
     * @return Количество токенов.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Перемещает токены `amount` со счета вызывающего аккунта в `recipient`.
     * @param recipient Получатель.
     * @param amount Количество токенов.
     * @return Логическое значение, указывающее, была ли операция выполнена успешно.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Возвращает оставшееся количество токенов, которые разрешено
     * потратить `spender` от имени `owner`.
     * @param owner Владелец.
     * @param spender Тратящий аккаунт.
     * @return Количество токенов.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Устанавливает количество токенов, которые разрешено
     * потратить `spender` от имени `owner`.
     * @param spender Тратящий аккаунт.
     * @param amount Количество токенов.
     * @return Логическое значение, указывающее, была ли операция выполнена успешно.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Перемещает доверенные токены от `sender` к `recipient`.
     * @param sender Отправитель.
     * @param recipient Получатель.
     * @param amount Количество токенов.
     * @return Логическое значение, указывающее, была ли операция выполнена успешно.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Вызывается, когда токены перемещаются с одной учетной записи на другую или при создании/удалении токенов.
     * @param from Отправитель.
     * @param to Получатель.
     * @param value Количество токенов.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Вызывается, когда выполняется { approve }.
     * @param owner Владелец.
     * @param spender Тратящий аккаунт.
     * @param value Количество токенов.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
